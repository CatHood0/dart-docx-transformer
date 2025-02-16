# Images

En `.docx`, las imágenes se representan dentro de `<w:drawing>` y `<wp:inline>` o `<wp:anchor>`, y pueden personalizarse con varios atributos. Aquí están los más usados:  

## 📌 **1. Alineación (`alignment`)**  
Se configura en `<w:pPr>` usando `<w:jc>`.  

```xml
<w:p>
  <w:pPr>
    <w:jc w:val="center"/> <!-- Alineación centrada -->
  </w:pPr>
  <w:r>
    <w:drawing>
      <!-- Aquí va la imagen -->
    </w:drawing>
  </w:r>
</w:p>
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "align": "center" } }
```

---

## 📌 **2. Tamaño (`width`, `height`)**  
Se define dentro de `<a:ext>` en la unidad EMU (1 cm ≈ 360000 EMU).  

```xml
<wp:extent cx="3048000" cy="2286000"/> <!-- 8.5 cm x 6.35 cm -->
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "width": 85, "height": 63.5 } }
```

---

## 📌 **3. Posición (Ajuste de Texto / `wrap`)**  
Se usa `<wp:inline>` (en línea con el texto) o `<wp:anchor>` (posicionado en la página).  

### **Texto envuelto (float left)**  
```xml
<wp:anchor>
  <wp:positionH relativeFrom="column">
    <wp:posOffset>0</wp:posOffset>
  </wp:positionH>
  <wp:positionV relativeFrom="paragraph">
    <wp:posOffset>0</wp:posOffset>
  </wp:positionV>
</wp:anchor>
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "float": "left" } }
```

---

## 📌 **4. Márgenes (`margin-top`, `margin-bottom`, etc.)**  
Se pueden controlar con `<wp:positionV>` y `<wp:positionH>`.  

```xml
<wp:positionH relativeFrom="column">
  <wp:posOffset>50000</wp:posOffset> <!-- 1.4 mm -->
</wp:positionH>
<wp:positionV relativeFrom="paragraph">
  <wp:posOffset>100000</wp:posOffset> <!-- 2.8 mm -->
</wp:positionV>
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "margin-top": 2.8, "margin-left": 1.4 } }
```

---

## 📌 **5. Bordes (`border`)**  
Los bordes de imágenes en `.docx` se aplican con `<a:ln>` dentro de `<a:graphic>`.  

```xml
<a:ln w="12700"> <!-- Borde de 0.35 mm -->
  <a:solidFill>
    <a:srgbClr val="FF0000"/> <!-- Rojo -->
  </a:solidFill>
</a:ln>
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "border": { "width": 0.35, "color": "#FF0000" } } }
```

---

## 📌 **6. Opacidad (`opacity`)**  
Se maneja con `<a:alpha>`, donde `100000` es opacidad total (100%).  

```xml
<a:alpha val="50000"/> <!-- 50% de opacidad -->
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "opacity": 50 } }
```

---

## 📌 **7. Redondeo de Bordes (`border-radius`)**  
En `.docx`, se usa `<a:roundRect>` en imágenes dentro de `<pic:spPr>`.  

```xml
<pic:spPr>
  <a:xfrm>
    <a:roundRect/>
  </a:xfrm>
</pic:spPr>
```

### **Delta**  
```json
{ "insert": { "image": "imagen.png" }, "attributes": { "border-radius": 10 } }
```

---

## 📌 **Resumen de atributos más usados**
| **Atributo Quill Delta** | **DOCX XML** |
|-----------------|------------------|
| `"align": "center"` | `<w:jc w:val="center"/>` |
| `"width": 85, "height": 63.5` | `<wp:extent cx="3048000" cy="2286000"/>` |
| `"float": "left"` | `<wp:anchor> ... </wp:anchor>` |
| `"margin-top": 2.8` | `<wp:positionV posOffset="100000"/>` |
| `"border": { "width": 0.35, "color": "#FF0000" }` | `<a:ln w="12700">` |
| `"opacity": 50` | `<a:alpha val="50000"/>` |
| `"border-radius": 10` | `<a:roundRect/>` |

---

### 🚀 **¿Necesitas ayuda implementándolo en tu código? ¿En qué lenguaje estás escribiendo el parser?**
