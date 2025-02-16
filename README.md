# Quill Delta to/from Docx

_No description yet_

Para insertar imágenes correctamente en un documento .docx desde un Quill Delta, debes seguir estos pasos sin romper la estructura del documento:
📌 Pasos para agregar imágenes en un .docx

Guardar las imágenes
    Si están en formato base64, conviértelas en archivos binarios (.png, .jpg, etc.).
    Si tienen una URL, descárgalas antes de insertarlas.

Incluirlas en media/ dentro del .docx
    En un documento .docx, las imágenes deben almacenarse en /word/media/imagenX.png dentro del ZIP.

Referenciarlas en document.xml.rels
    Dentro de /word/_rels/document.xml.rels, agrega una relación (<Relationship>), por ejemplo:

<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/imagen1.png"/>
Insertarlas en document.xml

En la parte donde deseas la imagen en el documento, agrega:

        <w:p>
          <w:r>
            <w:drawing>
              <wp:inline>
                <a:graphic>
                  <a:graphicData>
                    <pic:pic>
                      <pic:blipFill>
                        <a:blip r:embed="rId5"/>
                      </pic:blipFill>
                    </pic:pic>
                  </a:graphicData>
                </a:graphic>
              </wp:inline>
            </w:drawing>
          </w:r>
        </w:p>

Asegúrate de usar el mismo rIdX que definiste en document.xml.rels.

Los archivos .docx no admiten videos directamente, pero puedes insertarlos de dos formas:

    Como un hipervínculo a un video en línea (Ej. YouTube, Vimeo, un archivo en la web).
    Como un objeto incrustado (OLE Object), que almacena un archivo de video dentro del .docx (pero requiere que Word lo reproduzca correctamente).

📌 1. Insertar un video como hipervínculo

Si solo necesitas que el usuario haga clic en un enlace para ver el video, usa un hipervínculo en document.xml:

<w:p>
  <w:hyperlink r:id="rId10">
    <w:r>
      <w:rPr><w:color w:val="0000FF"/><w:u w:val="single"/></w:rPr>
      <w:t>Ver video</w:t>
    </w:r>
  </w:hyperlink>
</w:p>

Y en /word/_rels/document.xml.rels, agrega:

<Relationship Id="rId10" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"
  Target="https://www.youtube.com/watch?v=EXAMPLE" TargetMode="External"/>

Ventaja: Funciona en cualquier dispositivo.
Desventaja: No está dentro del .docx, requiere conexión a Internet.
📌 2. Insertar un video como un objeto OLE

Si necesitas incluir el video en el .docx, puedes hacerlo como un objeto OLE:

<w:object>
  <o:OLEObject Type="Embed" ProgID="MediaPlayer.MediaPlayer"
    ShapeID="2" DrawAspect="Content" ObjectID="_1303241561">
  </o:OLEObject>
</w:object>

Pasos para hacerlo correctamente:

    Guarda el video en /word/media/video1.mp4 dentro del .docx ZIP.
    Crea un objeto en document.xml.rels para vincularlo:

    <Relationship Id="rId11" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/media"
      Target="media/video1.mp4"/>

    En document.xml, usa un <w:object> con rId11.

Ventaja: El video se guarda dentro del .docx.
Desventaja: Solo funciona en Word de escritorio y puede requerir un reproductor externo.
📌 ¿Qué método usar?

    Si el video está en YouTube u otro servicio, usa hipervínculo.
    Si necesitas que esté dentro del .docx, usa OLE Object, pero Word puede no reproducirlo bien.

¿Quieres que te ayude a implementar esto en tu parser? 🚀
