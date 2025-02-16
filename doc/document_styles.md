PPara convertir atributos de Quill Delta a `.docx`, debes mapear cada atributo a su equivalente en XML dentro del documento. Aquí te explico cómo hacerlo para cada uno:  

## 📌 **1. Alineación (`alignment`)**
Quill Delta usa `alignment: left | right | center | justify`. En `document.xml`, esto se representa dentro de `<w:pPr>` con `<w:jc>`:  

```html
<w:p>
  <w:pPr>
    <w:jc w:val="center"/> <!-- center, left, right, justify -->
  </w:pPr>
  <w:r><w:t>Texto centrado</w:t></w:r>
</w:p>
```

### **Conversión desde Delta:**

```js
{ "insert": "Texto centrado", "attributes": { "align": "center" } }
```

---

## 📌 **2. Encabezados (`heading`)**

Quill usa `header: 1 | 2 | 3`, mientras que Word usa estilos de párrafo (`w:pStyle` con valores `Heading1`, `Heading2`, etc.).

```html
<w:p>
  <w:pPr>
    <w:pStyle w:val="Heading1"/> <!-- h1 -->
  </w:pPr>
  <w:r><w:t>Encabezado 1</w:t></w:r>
</w:p>
```

### **Conversión desde Delta:**
```js
{ "insert": "Encabezado 1", "attributes": { "header": 1 } }
```

---

## 📌 **3. Bloques de código (`code-block`)**
Los bloques de código en `.docx` se representan con una fuente monoespaciada (`Courier New`) y, opcionalmente, un fondo gris (`shading`).

```HTML
<w:p>
  <w:pPr>
    <w:pStyle w:val="Code"/> <!-- Un estilo predefinido para código -->
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Courier New"/>
      <w:shd w:fill="EEEEEE"/> <!-- Fondo gris claro -->
    </w:rPr>
    <w:t>print("Hola, mundo!")</w:t>
  </w:r>
</w:p>
```

### **Conversión desde Delta:**
```js
{ "insert": "print('Hola, mundo!')\n", "attributes": { "code-block": true } }

```

---
## 📌 **4. Citas (`blockquote`)**
Se representan con `w:pStyle w:val="Quote"` o usando una sangría en Word:

```html
<w:p>
  <w:pPr>
    <w:pStyle w:val="Quote"/>
  </w:pPr>
  <w:r><w:t>Este es un bloque de cita.</w:t></w:r>
</w:p>
```

### **Conversión desde Delta:**
```JS
{ "insert": "Este es un bloque de cita.", "attributes": { "blockquote": true } }
```

---

## 📌 **5. Sangría (`indentation`)**
Quill usa `indent: N`, donde `N` es el nivel de sangría. En `.docx`, se usa `<w:ind>`:

```html
<w:p>
  <w:pPr>
    <w:ind w:left="720"/> <!-- 720 = 0.5 pulgadas de sangría -->
  </w:pPr>
  <w:r><w:t>Texto con sangría</w:t></w:r>
</w:p>
```

📌 **Conversión desde Delta (nivel de sangría 2 → 1440 twips = 1 pulgada):**
```JS
{ "insert": "Texto con sangría", "attributes": { "indent": 2 } }
```

---

## 📌 **6. Dirección del texto (`direction`)**
Quill usa `direction: rtl` para textos en árabe/hebreo. En `.docx`, se usa `<w:bidi>`:

```html
<w:p>
  <w:pPr>
    <w:bidi/>
  </w:pPr>
  <w:r><w:t>مرحبا بالعالم</w:t></w:r>
</w:p>
```

### **Conversión desde Delta:**
```json
{ "insert": "مرحبا بالعالم", "attributes": { "direction": "rtl" } }
```

---

## **📌 Resumen de conversión**
| **Quill Delta** | **DOCX XML equivalente** |
|----------------|-------------------------|
| `"align": "center"` | `<w:jc w:val="center"/>` |
| `"header": 1` | `<w:pStyle w:val="Heading1"/>` |
| `"code-block": true` | `<w:rFonts w:ascii='Courier New'/>` |
| `"blockquote": true` | `<w:pStyle w:val="Quote"/>` |
| `"indent": 2` | `<w:ind w:left="1440"/>` |
| `"direction": "rtl"` | `<w:bidi/>` |

En `.docx`, puedes controlar el **color del texto** y el **color de fondo** usando las etiquetas `<w:color>` y `<w:shd>` dentro de `<w:rPr>` (propiedades de ejecución de texto).  

## 📌 **1. Cambiar el color del texto**
Usa `<w:color w:val="HEX"/>`, donde `HEX` es el código del color en formato hexadecimal sin `#`.  

### **Ejemplo: Texto en rojo (`#FF0000`)**
```html
<w:p>
  <w:r>
    <w:rPr>
      <w:color w:val="FF0000"/> <!-- Texto rojo -->
    </w:rPr>
    <w:t>Este es un texto rojo</w:t>
  </w:r>
</w:p>
```

### **Conversión desde Delta:**
```json
{ "insert": "Este es un texto rojo", "attributes": { "color": "#FF0000" } }
```

---

## 📌 **2. Cambiar el color de fondo del texto**
El fondo se controla con `<w:shd>` y el atributo `w:fill`, que acepta un código hexadecimal sin `#`.

### **Ejemplo: Texto con fondo amarillo (`#FFFF00`)**
```html
<w:p>
  <w:r>
    <w:rPr>
      <w:shd w:fill="FFFF00"/> <!-- Fondo amarillo -->
    </w:rPr>
    <w:t>Texto con fondo amarillo</w:t>
  </w:r>
</w:p>
```

### **Conversión desde Delta:**
```json
{ "insert": "Texto con fondo amarillo", "attributes": { "background": "#FFFF00" } }
```

---

## 📌 **3. Aplicar color y fondo al mismo texto**
Puedes combinar ambos atributos dentro de `<w:rPr>`.

### **Ejemplo: Texto azul (`#0000FF`) con fondo gris (`#CCCCCC`)**
```html
<w:p>
  <w:r>
    <w:rPr>
      <w:color w:val="0000FF"/> <!-- Texto azul -->
      <w:shd w:fill="CCCCCC"/> <!-- Fondo gris -->
    </w:rPr>
    <w:t>Texto azul con fondo gris</w:t>
  </w:r>
</w:p>
```

### **Conversión desde Delta:**
```json
{ "insert": "Texto azul con fondo gris", "attributes": { "color": "#0000FF", "background": "#CCCCCC" } }
```

---

## 📌 **4. Aplicar color de fondo a un párrafo completo**
Si deseas aplicar el fondo a un **párrafo entero**, mueve `<w:shd>` a `<w:pPr>`:

```html
<w:p>
  <w:pPr>
    <w:shd w:fill="EEEEEE"/> <!-- Fondo gris claro para todo el párrafo -->
  </w:pPr>
  <w:r><w:t>Párrafo con fondo gris</w:t></w:r>
</w:p>
```

### **Conversión desde Delta (para todo el párrafo):**
```json
{ "insert": "Párrafo con fondo gris\n", "attributes": { "background": "#EEEEEE" } }
```

---

## **📌 Resumen de conversión**
| **Quill Delta** | **DOCX XML equivalente** |
|----------------|-------------------------|
| `"color": "#FF0000"` | `<w:color w:val="FF0000"/>` |
| `"background": "#FFFF00"` (solo texto) | `<w:shd w:fill="FFFF00"/>` dentro de `<w:rPr>` |
| `"background": "#EEEEEE"` (párrafo) | `<w:shd w:fill="EEEEEE"/>` dentro de `<w:pPr>` |

---

## 🚀 **¿Necesitas una función para automatizar esto en tu parser?**
Si me dices en qué lenguaje lo estás programando (Dart, Python, JS), te puedo ayudar a convertir estos atributos en código. 😃
