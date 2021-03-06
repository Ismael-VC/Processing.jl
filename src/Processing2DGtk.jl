module ProcessingStd

using Tk
using Cairo
using Color
using Tau

import Cairo: rotate, translate, scale

include("constants.jl")

export animate, coordSystem
export size, Height, Width, displayHeight, displayWidth
export focused, cursor, noCursor
# export frameCount, frameRate
# export createShape, loadShape
export arc, ellipse, line, point, quad, rect, triangle
export bezier
# export bezierDetail, bezierPoint, bezierTangent, curve, curveDetail, curvePoint, curveTangent, curveTightness
export strokeWeight, strokeCap, strokeJoin, noSmooth, smooth
export ellipseMode, rectMode
# export beginShape, endShape, vertex
# export bezierVertex, curveVertex, quadraticVertex
# export shape, shapeMode
export mouseButton, mouseClicked, mouseDragged, mouseMoved, mousePressed
export mouseReleased, mouseWheel, mouseX, mouseY, pmouseX, pmouseY
export background, fill, noFill, colorMode, noStroke, stroke
# export applyMatrix
export popMatrix, printMatrix, pushMatrix, resetMatrix, rotate
export scale, shearX, shearY, translate
export alpha, blue, brightness, color, green, hue, lerpColor, red, saturation
# export createImage
export image, loadImage, noTint
# export imageMode, tint, requestImage
# export texture, textureMode, textureWrap
# export blend, copy, filter, get, loadPixels, set, updatePixels
# export blendMode
# export createGraphics
export createFont, text, textFont
# export loadFont
export textSize, textWidth
# export textAlign, textLeading, textMode
# export textAscent, textDescent

# state variables

# bgCol = RGB(0.94, 0.92, 0.9) #pleasant default background color from Jeff Bezanson's Fractals iJulia notebook (http://nbviewer.ipython.org/url/beowulf.csail.mit.edu/18.337/fractals.ipynb)
# fillStuff = true #should drawing elements be filled or not?
# fillCol = RGB(0.7,0.7,0.7) #color to be used for filling elements
# strokeStuff = true #should drawing elements be stroked or not?
# strokeCol = RGB(0,0,0) #color to be used for stroking elements
# h = 275 #height of display window
# w = 275 #width of display window
# left = -1 #scaling of left-hand of x-axis in plotting coordinate system
# right = 1 #scaling of right-hand of x-axis in plotting coordinate system
# top = 1 #scaling of top-hand of x-axis in plotting coordinate system
# bottom = -1 #scaling of bottom-hand of x-axis in plotting coordinate system
# cMode = "RGB" #what color space are we using for colors?
# title = "Processing.jl" #window title
# ellipseMode = CENTER #specify ellipses center, width, and height when drawing it by default
# rectMode = CORNER #specficy rects upper-left corner coordinate and its width and height when drawing it by default
# cmX
# cmY
# pmX
# pmY
# mouse1Pressed
# mouse2Pressed
# mouse3Pressed
# mouse1Released
# mouse2Released
# mouse3Released
# mouse1Dragged

# state structure

type stateStruct
    bgCol::ColorValue
    fillStuff::Bool
    fillCol::ColorValue
    strokeStuff::Bool
    strokeCol::ColorValue
    h::Int
    w::Int
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    cMode::String
    title::String
    tintStuff::Bool
    ellipseMode::Int
    rectMode::Int
    cmX::Int
    cmY::Int
    pmX::Int
    pmY::Int
    mouse1Pressed::Bool
    mouse2Pressed::Bool
    mouse3Pressed::Bool
    mouse1Released::Bool
    mouse2Released::Bool
    mouse3Released::Bool
    mouse1Dragged::Bool
end

# initialize state structure and open drawing window
state = stateStruct(RGB(0.94, 0.92, 0.9), true, RGB(0.7,0.7,0.7), true, RGB(0,0,0), 275, 275, -1., 1., 1., -1., "RGB", "Processing.jl", false, CENTER, CORNER, 0, 0, 0, 0, false, false, false, true, true, true, false)
export state

function size(w, h)
    state.w = w
    state.h = h

    win = Tk.Window(state.title, state.w, state.h) #main drawing window
    c = Tk.Canvas(win)
    Tk.pack(c)
    cr = Tk.getgc(c) #main drawing context
    s = Tk.cairo_surface(c) #main drawing surface

    c.mouse.button1press = function (c, x, y)
        state.mouse1Pressed = true
    end
    c.mouse.button2press = function (c, x, y)
        state.mouse2Pressed = true
    end
    c.mouse.button3press = function (c, x, y)
        state.mouse3Pressed = true
    end
    c.mouse.button1release = function (c, x, y)
        state.mouse1Pressed = false
        state.mouse1Dragged = false
    end
    c.mouse.button2release = function (c, x, y)
        state.mouse2Pressed = false
    end
    c.mouse.button3release = function (c, x, y)
        state.mouse3Pressed = false
    end
    c.mouse.motion = function (c, x, y)
        state.pmX = state.cmX; state.pmY = state.cmY
        state.cmX = x; state.cmY = y
    end
    c.mouse.button1motion = function (c, x, y)
        state.pmX = state.cmX; state.pmY = state.cmY
        state.cmX = x; state.cmY = y
        state.mouse1Dragged = true
    end

    # initialize simulated Processing environment

    set_source(cr, state.bgCol)
    paint(cr)
    set_source(cr, state.strokeCol)
    Tk.reveal(c)
    Tk.update()

    set_line_width(cr, 1) # a pleasing default line width

    return win, c, cr, s
end

function size()
    win = Tk.Window(state.title, state.w, state.h) #main drawing window
    c = Tk.Canvas(win)
    Tk.pack(c)
    cr = Tk.getgc(c) #main drawing context
    s = Tk.cairo_surface(c) #main drawing surface

    c.mouse.button1press = function (c, x, y)
        state.mouse1Pressed = true
    end
    c.mouse.button2press = function (c, x, y)
        state.mouse2Pressed = true
    end
    c.mouse.button3press = function (c, x, y)
        state.mouse3Pressed = true
    end
    c.mouse.button1release = function (c, x, y)
        state.mouse1Pressed = false
        state.mouse1Dragged = false
    end
    c.mouse.button2release = function (c, x, y)
        state.mouse2Pressed = false
    end
    c.mouse.button3release = function (c, x, y)
        state.mouse3Pressed = false
    end
    c.mouse.motion = function (c, x, y)
        state.pmX = state.cmX; state.pmY = state.cmY
        state.cmX = x; state.cmY = y
    end
    c.mouse.button1motion = function (c, x, y)
        state.pmX = state.cmX; state.pmY = state.cmY
        state.cmX = x; state.cmY = y
        state.mouse1Dragged = true
    end

    # initialize simulated Processing environment

    set_source(cr, state.bgCol)
    paint(cr)
    set_source(cr, state.strokeCol)
    Tk.reveal(c)
    Tk.update()

    set_line_width(cr, 1) # a pleasing default line width

    return win, c, cr, s
end

# special Processing.jl animate() command for smoother animations
function animate()
    Tk.reveal(c)
    Tk.update()
    new_path(cr)
end

# allow user to control coordinate system
function coordSystem(left, right, top, bottom)
    Base.Graphics.set_coords(cr, 0, 0, state.w, state.h, left, right, top, bottom)
end

# Environment

# exported environment variables
displayHeight = tcl("winfo", "screenwidth", win)
displayWidth = tcl("winfo", "screenheight", win)

function cursor(cursorType)
    if cursorType == ARROW
        tcl("cursors", "arrow")
    elseif cursorType == CROSS
        tcl("cursors", "cross")
    elseif cursorType == HAND
        @linux_only tcl("cursors", "hand1")
        @windows_only tcl("cursors", "hand1")
        @osx_only tcl("cursors", "pointinghand")
    elseif cursorType == MOVE
        @linux_only tcl("cursors", "target")
        @windows_only tcl("cursors", "size")
        @osx_only tcl("cursors", "pointinghand")
    elseif cursorType == TEXT
        tcl("cursors", "ibeam")
    elseif cursorType == WAIT
        @linux_only tcl("cursors", "clock")
        @windows_only tcl("cursors", "wait")
        @osx_only tcl("cursors", "spinning")
    end
end

function focused()
    if isempty(tcl("focus"))
        return false
    else
        return true
    end
end

#frameCount
#frameRate

function Height()
	return state.h
end

function noCursor()
    @windows_only tcl("cursors", "no")
end

function Width()
	return state.w
end

# Shape

#createShape
#loadShape

## 2D Primitives

function arc(xcent, ycent, ellipseW, ellipseH, angle1, angle2, mode)
    save(cr)
    move_to(cr, xcent, ycent)
    scale(cr, ellipseW, ellipseH)
    new_sub_path(cr)
    if mode == OPEN
        arc(cr, 0, 0, 1, angle1, angle2)
    elseif mode == PIE
    end
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill(cr)
    end
    if mode == CHORD
        move_to(cos(angle1), sin(angle1))
        line_to(cos(angle2), sin(angle2))
    end
    restore(cr)
end

function ellipse(xcent, ycent, ellipseW, ellipseH)
    save(cr)
    if state.ellipseMode == RADIUS
        move_to(cr, xcent, ycent)
        scale(cr, ellipseW/2, ellipseH/2)
    elseif state.ellipseMode == CENTER
        move_to(cr, xcent, ycent)
        scale(cr, ellipseW, ellipseH)
    elseif state.ellipseMode == CORNER
        move_to(cr, xcent+ellipseW/2, ycent+ellipseH/2)
        scale(cr, ellipseW, ellipseH)
    elseif state.ellipseMode == CORNERS
        move_to(cr, xcent, ycent)
        scale(cr, ellipseW, ellipseH)
    end
    new_sub_path(cr)
    arc(cr, 0, 0, 1, 0, 2*pi)
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill(cr)
    end
    restore(cr)
end

function line(x1, y1, x2, y2)
    move_to(cr,x1,y1)
    line_to(cr,x2,y2)
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke(cr)
    end
end

function point(x, y)
    move_to(cr,x,y)
    dx, dy = device_to_user_distance!(cr,[1., 0.])
    rectangle(cr,x,y,dx,dx)
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke(cr)
    end
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4)
    move_to(cr, x1, y1)
    line_to(cr, x2, y2)
    line_to(cr, x3, y3)
    line_to(cr, x4, y4)
    close_path(cr)
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill(cr)
    end
end

function rect(xtopleft, ytopleft, width, height)
    if state.rectMode == CORNER
        rectangle(cr, xtopleft, ytopleft, width, height)
    elseif state.rectMode == CORNERS # in this case, width and height are
                                     # reinterpreted as (x,y) coords of
                                     # bottom-right corner
        rectangle(cr, xtopleft, ytopleft, width-xtopleft, height-ytopleft)
    elseif state.rectMode == CENTER
        rectangle(cr, xtopleft-width/2, ytopleft-height/2, width, height)
    elseif state.rectMode == RADIUS
        rectangle(cr, xtopleft-width/2, ytopleft-height/2, width/2, height/2)
    end
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill(cr)
    end
end

function triangle(x1,y1,x2,y2,x3,y3)
    move_to(cr, x1, y1)
    line_to(cr, x2, y2)
    line_to(cr, x3, y3)
    close_path(cr)
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill(cr)
    end
end

## Curves

function bezier(x1, y1, x2, y2, x3, y3, x4, y4)
    move_to(cr, x1, y1);
    curve_to(cr, x2, y2, x3, y3, x4, y4);
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke_preserve(cr)
    end
end

#bezierDetail
#bezierPoint
#bezierTangent
#curve
#curveDetail
#curvePoint
#curveTangent
#curveTightness

## Attributes

function ellipseMode(eMode)
    state.ellipseMode = eMode
end

function noSmooth()
    set_antialias(cr, Cairo.ANTIALIAS_NONE)
end

function rectMode(rMode)
    state.rectMode = rMode
end

function smooth()
    set_antialias(cr, Cairo.ANTIALIAS_BEST)
end

function strokeCap(capType)
    if capType == ROUND
        set_line_cap(cr, Cairo.CAIRO_LINE_CAP_ROUND)
    elseif capType == SQUARE
        set_line_cap(cr, Cairo.CAIRO_LINE_CAP_BUTT)
    elseif capType == PROJECT
        set_line_cap(cr, Cairo.CAIRO_LINE_CAP_SQUARE)
    end
end

function strokeJoin(joinType)
    if joinType == MITER
        set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_MITER)
    elseif joinType == BEVEL
        set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_BEVEL)
    elseif joinType == ROUND
        set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_ROUND)
    end
end

function strokeWeight(newWeight)
    set_line_width(cr, newWeight)
end

## Vertex

# function beginShape()
#
# end

#bezierVertex
#curveVertex

# function endShape()
#
# end

#quadraticVertex

# function vertex(x,y)
#
# end

## Loading & Displaying

#shape
#shapeMode

## Input

# Mouse

function mouseButton()
    if state.mouse1Pressed
        return LEFT
    elseif state.mouse2Pressed
        return CENTER
    elseif state.mouse3Pressed
        return RIGHT
    end
end

function mouseClicked()

end

function mouseDragged()

end

function mouseMoved()

end

function mousePressed()
    if state.mouse1Pressed || state.mouse2Pressed || state.mouse3Pressed
        return true
    else
        return false
    end
end

function mouseReleased()

end

function mouseWheel()

end

function mouseX()
    return state.cmX
end

function mouseY()
    return state.cmX
end

function pmouseX()
    return state.pmX
end

function pmouseY()
    return state.pmY
end

## Transform

#applyMatrix()

function popMatrix()
    restore(cr)
end

function printMatrix()
    println(get_matrix(cr))
end

function pushMatrix()
    save(cr)
end

function resetMatrix()
    identity_matrix(cr)
end

function rotate(ang)
    Cairo.rotate(cr, ang)
end

function scale(sx, sy)
    Cairo.scale(cr, sx, sy)
end

#shearX()
#shearY()

function translate(x, y)
    Cairo.translate(cr, x, y)
end

# Color

## Setting

function background(r, g, b, a)
    state.bgCol = RGB(r, g, b)
    set_source(cr, state.bgCol)
    paint(cr)
end

function colorMode(mode::String)
    state.cMode = mode
end

function fill(r, g, b, a)
    if state.fillStuff == false
        state.fillStuff = true
    end
    if state.cMode == "RGB"
        state.fillCol = RGB(r, g, b)
    else
    end
end

function noFill()
    state.fillStuff = false
end

function noStroke()
    state.strokeStuff = false
end

function stroke(r, g, b, a)
    if state.strokeStuff == false
        state.strokeStuff = true
    end
    if state.cMode == "RGB"
        state.strokeCol = RGB(r, g, b)
    else
    end
end

## Creating & Reading

function alpha(c::ColorValue)
    return c.a
end

function blue(c::ColorValue)
    return c.b
end

function brightness(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.v
end

function color(r, g, b)
    return RGB(r, g, b)
end

function green(c::ColorValue)
    return c.g
end

function hue(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.h
end

function lerpColor(c1::ColorValue, c2::ColorValue, amt::Float32)
    return weighted_color_mean(amt, c1, c2)
end

function red(c::ColorValue)
    return c.r
end

function saturation(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.s
end

# Image

#function createImage(x, y, colorSpace::String)
#
#end

## Loading & Displaying

function image(img, x, y, w, h)
    Cairo.image(cr, img, x, y, w, h)
end

#imageMode

function loadImage(fileName::String)
    return read_from_png(fileName)
end

function noTint()
    state.tintStuff = false
end

#requestImage

#function tint()
#
#end

## Textures

#texture
#textureMode
#textureWrap

## Pixels

#blend
#copy
#filter
#get
#loadPixels
#set
#updatePixels

# Rendering

# function blendMode()
#
# end

#createGraphics

# Typography

## Loading & Displaying

function createFont(fontName::String, fontSize::Float32)
    set_font_face(cr, fontName)
    set_font_size(cr, fontSize)
end

#loadFont

function text(str::String, x, y)
    move_to(cr, x, y);
    text_path(cr, str);
    if state.fillStuff
        set_source(cr, state.fillCol)
        fill_preserve(cr)
    end
    if state.strokeStuff
        set_source(cr, state.strokeCol)
        stroke(cr)
    end
end

function textFont(fontName::String)
    set_font_face(cr, fontName)
end

## Attributes

#function textAlign()
#
#end

#textLeading
#textMode

function textSize(fontSize)
    set_font_size(cr, fontSize)
end

function textWidth(str::String)
    extents = text_extents(cr, str)
    return extents[3]
end

## Metrics

#function textAscent(str::String)
#    extents = scaled_font_extents(cr, str)
#    return extents[1]
#end

#function textDescent(str::String)
#    extents = scaled_font_extents(cr, str)
#    return extents[2]
#end

end # module Processing
