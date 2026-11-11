import QtQuick
import QtQuick.Shapes
import qs.DockApp

// Background of the dock: a fill with a gradient border ring around it.
// Fill and border are separate layers, so each has its own opacity and the
// border does not tint a translucent fill. borderOpacity follows the fill or
// stays at 80%, see DockTheme.borderOpacity().
Item {
    id: root

    property real radius: 16
    property real borderWidth: 2
    property color colorTop: DockTheme.primary
    property color colorBottom: DockTheme.on_primary
    property color fillColor: DockTheme.background
    property real fillOpacity: 1.0
    property real borderOpacity: DockTheme.borderOpacity(fillOpacity)

    readonly property real innerRadius: Math.max(0, radius - borderWidth)

    // Background fill, inset by the border thickness
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.borderWidth
        radius: root.innerRadius
        color: root.fillColor
        opacity: root.fillOpacity
    }

    // Gradient border: the outer rounded rectangle minus the inner one
    Shape {
        anchors.fill: parent
        visible: root.borderWidth > 0
        opacity: root.borderOpacity
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            strokeWidth: -1
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: 0; y1: 0
                x2: 0; y2: root.height
                GradientStop { position: 0.0; color: root.colorTop }
                GradientStop { position: 1.0; color: root.colorBottom }
            }

            PathRectangle {
                x: 0; y: 0
                width: root.width; height: root.height
                radius: root.radius
            }
            PathRectangle {
                x: root.borderWidth; y: root.borderWidth
                width: Math.max(0, root.width - 2 * root.borderWidth)
                height: Math.max(0, root.height - 2 * root.borderWidth)
                radius: root.innerRadius
            }
        }
    }
}
