package com.fusio3d.app

import org.json.JSONObject

/** A customer request for a 3D print. No pricing yet — this is an inquiry. */
data class OrderRequest(
    val name: String,
    val contact: String,
    val description: String,
    val material: String,
    val color: String,
    val quantity: Int,
    val referenceLink: String,
    val notes: String,
) {
    fun toJson(): String = JSONObject().apply {
        put("name", name)
        put("contact", contact)
        put("description", description)
        put("material", material)
        put("color", color)
        put("quantity", quantity)
        put("referenceLink", referenceLink)
        put("notes", notes)
        put("source", "fusio3d-android")
    }.toString()

    /** Human-readable body used for the email fallback. */
    fun toEmailBody(): String = buildString {
        appendLine("Нова заявка за 3D печат — Fusio3D")
        appendLine()
        appendLine("Име: $name")
        appendLine("Контакт: $contact")
        appendLine("Брой: $quantity")
        appendLine("Материал: $material")
        appendLine("Цвят: $color")
        if (referenceLink.isNotBlank()) appendLine("Референтен линк: $referenceLink")
        appendLine()
        appendLine("Какво да се принтира:")
        appendLine(description)
        if (notes.isNotBlank()) {
            appendLine()
            appendLine("Бележки:")
            appendLine(notes)
        }
    }
}
