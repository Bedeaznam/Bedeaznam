# Builds a ready-to-edit Blender scene for the wooden ring box (PLA Wood look).
# Run headless:  blender -b -P build_blend.py
# Produces: wood_ring_box.blend  and  renders/blender_preview.png
import bpy, os, math, addon_utils
from mathutils import Euler, Vector, Matrix

HERE = os.path.dirname(os.path.abspath(__file__)) if "__file__" in globals() else os.getcwd()
S = 0.02  # mm -> Blender units

# hinge params (must match the .scad)
W = 58; knuckle_r = 4.2; base_h = 3.4 + 18
hinge_y = W + knuckle_r - 1.2
hinge_z = base_h + knuckle_r
wall = 3.4; floor_t = 3.4; insert_clear = 0.6

addon_utils.enable("io_mesh_stl")
bpy.ops.wm.read_factory_settings(use_empty=True)

def imp(name):
    bpy.ops.import_mesh.stl(filepath=os.path.join(HERE, name + ".stl"))
    o = bpy.context.selected_objects[0]; o.name = name; return o

def wood_mat(name, base_col, grain_col):
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; bsdf = nt.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.72
    # procedural wood grain: wave texture -> color ramp -> base color
    tex = nt.nodes.new("ShaderNodeTexWave"); tex.wave_type = "BANDS"
    tex.inputs["Scale"].default_value = 3.0
    tex.inputs["Distortion"].default_value = 12.0
    tex.inputs["Detail"].default_value = 5.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (*base_col, 1)
    ramp.color_ramp.elements[1].color = (*grain_col, 1)
    mp = nt.nodes.new("ShaderNodeMapping"); co = nt.nodes.new("ShaderNodeTexCoord")
    nt.links.new(co.outputs["Object"], mp.inputs["Vector"])
    nt.links.new(mp.outputs["Vector"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
    return m

def velvet_mat(name, col):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*col, 1)
    b.inputs["Roughness"].default_value = 0.95
    if "Sheen" in b.inputs: b.inputs["Sheen"].default_value = 1.0
    return m

wood  = wood_mat("PLA_Wood", (0.42, 0.26, 0.13), (0.24, 0.13, 0.06))
wood2 = wood_mat("PLA_Wood_Lid", (0.46, 0.29, 0.15), (0.26, 0.15, 0.07))
velvet = velvet_mat("Velvet", (0.05, 0.12, 0.06))  # deep green velvet

base = imp("base"); lid = imp("lid"); insert = imp("insert")
for o in (base, lid, insert): o.scale = (S, S, S)

base.location = (0, 0, 0)
insert.location = ((wall+insert_clear)*S, (wall+insert_clear)*S, floor_t*S)

# the lid STL is printed flat, with its hinge axis one knuckle radius above the
# bed; lift it onto the base, then swing it ~105 deg about the shared axis
ang = math.radians(105)
Rx = Matrix.Rotation(ang, 3, 'X')
pivot = Vector((0, hinge_y, hinge_z)) * S
seat = Vector((0, 0, base_h)) * S
lid.rotation_euler = Euler((ang, 0, 0), 'XYZ')
lid.location = pivot + (Rx @ (seat - pivot))

base.data.materials.append(wood)
lid.data.materials.append(wood2)
insert.data.materials.append(velvet)

# world + lights + camera
world = bpy.data.worlds.new("World"); bpy.context.scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (0.05, 0.05, 0.06, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 0.9

bpy.context.view_layer.update()
lo = Vector((1e9,)*3); hi = Vector((-1e9,)*3)
for o in (base, lid, insert):
    for c in o.bound_box:
        wc = o.matrix_world @ Vector(c)
        lo = Vector((min(lo[i], wc[i]) for i in range(3)))
        hi = Vector((max(hi[i], wc[i]) for i in range(3)))
center = (lo + hi) / 2; diag = (hi - lo).length

def look_at(o, t):
    o.rotation_euler = (o.location - t).to_track_quat('Z', 'Y').to_euler()

key = bpy.data.lights.new("Key", "AREA"); key.energy = 500; key.size = diag*1.2
ko = bpy.data.objects.new("Key", key); bpy.context.collection.objects.link(ko)
ko.location = center + Vector((diag*0.9, -diag*0.9, diag*1.1)); look_at(ko, center)
fill = bpy.data.lights.new("Fill", "AREA"); fill.energy = 220; fill.size = diag*2
fo = bpy.data.objects.new("Fill", fill); bpy.context.collection.objects.link(fo)
fo.location = center + Vector((-diag, -diag*0.6, diag*0.6)); look_at(fo, center)

cam = bpy.data.cameras.new("Camera"); cam.lens = 55
co = bpy.data.objects.new("Camera", cam); bpy.context.collection.objects.link(co)
co.location = center + Vector((diag*1.1, -diag*1.3, diag*0.9)); look_at(co, center)
bpy.context.scene.camera = co

sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"
sc.eevee.taa_render_samples = 128
sc.eevee.use_gtao = True
sc.render.resolution_x = 1000; sc.render.resolution_y = 800

bpy.ops.wm.save_as_mainfile(filepath=os.path.join(HERE, "wood_ring_box.blend"))
os.makedirs(os.path.join(HERE, "renders"), exist_ok=True)
sc.render.filepath = os.path.join(HERE, "renders", "blender_preview.png")
bpy.ops.render.render(write_still=True)
print("SAVED")
