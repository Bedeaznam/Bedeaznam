# Builds a ready-to-edit Blender scene for the Y7 "Book of Vows" ring box.
# Run headless:
#   blender -b -P build_blend.py
# Produces: book_of_vows.blend  and  renders/blender_preview.png
import bpy, os, math, addon_utils
from mathutils import Euler

HERE = os.path.dirname(os.path.abspath(__file__)) if "__file__" in globals() else os.getcwd()
S = 0.02  # scale mm -> Blender units (nice viewport size)

addon_utils.enable("io_mesh_stl")

# ---- clean scene ----
bpy.ops.wm.read_factory_settings(use_empty=True)

def imp(name):
    path = os.path.join(HERE, name + ".stl")
    bpy.ops.import_mesh.stl(filepath=path)
    o = bpy.context.selected_objects[0]
    o.name = name
    return o

def mat(name, color, metallic=0.0, rough=0.5, sheen=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1.0)
    b.inputs["Metallic"].default_value = metallic
    b.inputs["Roughness"].default_value = rough
    if "Sheen" in b.inputs:
        b.inputs["Sheen"].default_value = sheen
    return m

leather = mat("Y7_Leather", (0.16, 0.03, 0.05), 0.0, 0.55)
gold    = mat("Y7_Gold",    (0.83, 0.66, 0.22), 1.0, 0.28)
velvet  = mat("Y7_Velvet",  (0.45, 0.03, 0.07), 0.0, 0.9, sheen=1.0)

base   = imp("base")
cover  = imp("cover")
insert = imp("insert")

# scale
for o in (base, cover, insert):
    o.scale = (S, S, S)

# positions (mm * S). Base at origin.
base.location = (0, 0, 0)

# insert seated in cavity: (spine_wall+clear, wall+clear, floor_t)
insert.location = (6.6 * S, 3.8 * S, 3.0 * S)

# cover hinged open ~110 deg about spine top edge (x=0, z=base_h=23mm)
cover.rotation_euler = Euler((0, math.radians(-110), 0), "XYZ")
cover.location = (0, 0, 23 * S)

# materials
base.data.materials.append(leather)
cover.data.materials.append(leather)
insert.data.materials.append(velvet)

# shade smooth on cover edges? keep flat for print accuracy
# ---- lighting ----
world = bpy.data.worlds.new("World"); bpy.context.scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (0.02, 0.02, 0.03, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 0.4

from mathutils import Vector

# compute world-space bounding box of the three parts
bpy.context.view_layer.update()
lo = Vector(( 1e9,  1e9,  1e9))
hi = Vector((-1e9, -1e9, -1e9))
for o in (base, cover, insert):
    for c in o.bound_box:
        wc = o.matrix_world @ Vector(c)
        lo = Vector((min(lo[i], wc[i]) for i in range(3)))
        hi = Vector((max(hi[i], wc[i]) for i in range(3)))
center = (lo + hi) / 2
diag = (hi - lo).length

def look_at(obj, target):
    d = (obj.location - target)
    obj.rotation_euler = d.to_track_quat('Z', 'Y').to_euler()

key = bpy.data.lights.new("Key", "AREA"); key.energy = 500; key.size = diag*1.2
ko = bpy.data.objects.new("Key", key); bpy.context.collection.objects.link(ko)
ko.location = center + Vector((diag*0.9, -diag*0.9, diag*1.1)); look_at(ko, center)

fill = bpy.data.lights.new("Fill", "AREA"); fill.energy = 220; fill.size = diag*2
fo = bpy.data.objects.new("Fill", fill); bpy.context.collection.objects.link(fo)
fo.location = center + Vector((-diag, -diag*0.6, diag*0.6)); look_at(fo, center)

# ---- camera ----
cam = bpy.data.cameras.new("Camera"); cam.lens = 50
co = bpy.data.objects.new("Camera", cam); bpy.context.collection.objects.link(co)
co.location = center + Vector((diag*1.15, -diag*1.35, diag*0.95))
look_at(co, center)
bpy.context.scene.camera = co

world.node_tree.nodes["Background"].inputs[1].default_value = 0.8

# ---- render settings (Cycles CPU, safe headless) ----
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"
sc.eevee.taa_render_samples = 128
sc.eevee.use_gtao = True
sc.eevee.use_ssr = True
sc.render.resolution_x = 1000
sc.render.resolution_y = 800
sc.render.film_transparent = False

# save blend
blend_path = os.path.join(HERE, "book_of_vows.blend")
bpy.ops.wm.save_as_mainfile(filepath=blend_path)

# render preview
os.makedirs(os.path.join(HERE, "renders"), exist_ok=True)
sc.render.filepath = os.path.join(HERE, "renders", "blender_preview.png")
bpy.ops.render.render(write_still=True)
print("SAVED", blend_path)
