from moose import Annotator
from PyQt4.QtGui import QColor
import numpy as np
import os
import config
import pickle
import random
import matplotlib

colormap_file = open(os.path.join(config.settings[config.KEY_COLORMAP_DIR], 'rainbow2.pkl'),'rb')
colorMap = pickle.load(colormap_file)
colormap_file.close()

ignoreColor= ["mistyrose","antiquewhite","aliceblue","azure","bisque","black","blanchedalmond","blue","cornsilk","darkolivegreen","darkslategray","dimgray","floralwhite","gainsboro","ghostwhite","honeydew","ivory","lavender","lavenderblush","lemonchiffon","lightcyan","lightgoldenrodyellow","lightgray","lightyellow","linen","mediumblue","mintcream","navy","oldlace","papayawhip","saddlebrown","seashell","snow","wheat","white","whitesmoke"]
matplotcolor = {}
for name,hexno in matplotlib.colors.cnames.iteritems():
    matplotcolor[name]=hexno

def getRandColor():
    k = random.choice(matplotcolor.keys())
    if k in ignoreColor:
        return getRandColor()
    else:
        print " l =",matplotcolor[k]
        return QColor(matplotcolor[k])

def getRandColor1():
    color = (np.random.randint(low=0, high=255, size=3)).tolist()
    if not all((x <= 65 or x >= 105) for x in (color[0],color[1],color[2])):
        return QColor(color[0],color[1],color[2])
    else:
        return getRandColor()
    

def getColor(iteminfo):
    """ Getting a textcolor and background color for the given  mooseObject \
        If textcolor is empty replaced with green \
           background color is empty replaced with blue
           if textcolor and background is same as it happend in kkit files \
           replacing textcolor with random color\
           The colors are not valid there are siliently replaced with some values \
           but while model building can raise an exception
    """
    textcolor = Annotator(iteminfo).getField('textColor')
    bgcolor = Annotator(iteminfo).getField('color')
    if(textcolor == ''): textcolor = 'green'
    if(bgcolor == ''): bgcolor = 'blue'
    if(textcolor == bgcolor):textcolor = getRandColor()
    textcolor = colorCheck(textcolor,"fc")
    bgcolor = colorCheck(bgcolor,"bg")
    return(textcolor,bgcolor)

def colorCheck(fc_bgcolor,fcbg):
    """ textColor or background can be anything like string or tuple or list \
        if string its taken as colorname further down in validColorcheck checked for valid color, \
        but for tuple and list its taken as r,g,b value.
    """
    if isinstance(fc_bgcolor,str):
        if fc_bgcolor.startswith("#"):
            fc_bgcolor = QColor(fc_bgcolor)
        elif fc_bgcolor.isdigit():
            """ color is int  a map from int to r,g,b triplets from pickled color map file """
            tc = int(fc_bgcolor)
            tc = 2*tc
            pickledColor = colorMap[tc]
            fc_bgcolor = QColor(*pickledColor)

        elif fc_bgcolor.isalpha() or fc_bgcolor.isalnum():
            fc_bgcolor = validColorcheck(fc_bgcolor)
        else:
            fc_bgcolor = QColor(*eval(fc_bgcolor))
            # fc_bgcolor = validColorcheck(fc_bgcolor)
    return(fc_bgcolor)

def validColorcheck(color):
	''' 
        Both in Qt4.7 and 4.8 if not a valid color it makes it as back but in 4.7 there will be a warning mssg which is taken here
        checking if textcolor or backgroundcolor is valid color, if 'No' making white color as default
        where I have not taken care for checking what will be backgroundcolor for textcolor or textcolor for backgroundcolor 
    '''
        if QColor(color).isValid():
            return (QColor(color))
        else:
            return(QColor("white"))


def moveMin(reference, collider, layoutPt,margin):
    referenceRect = reference.sceneBoundingRect()
    colliderRect = collider.sceneBoundingRect()
    xDistance = referenceRect.x() + referenceRect.width() / 2.0 + colliderRect.width() / 2.0 + margin - colliderRect.x()
    yDistance = 0.0     
    if colliderRect.y() < referenceRect.y():
        yDistance = (referenceRect.y() - referenceRect.height() / 2.0 - colliderRect.height() / 2.0 - margin) - colliderRect.y()
    else:
        yDistance = referenceRect.y() + referenceRect.height() / 2.0 + colliderRect.height() / 2.0 + margin - colliderRect.y()

    #if xDistance > yDistance:
    collider.moveBy(xDistance, yDistance)
    #else:
    #   collider.moveBy(xDistance, 0.0)
    layoutPt.drawLine_arrow(itemignoreZooming=False)

def moveX(reference, collider, layoutPt, margin):
    referenceRect = reference.sceneBoundingRect()
    colliderRect = collider.sceneBoundingRect()
    xc = abs(referenceRect.topRight().x()) - abs(colliderRect.topLeft().x())+margin
    yc = 0.0
    collider.moveBy(xc,yc)
    layoutPt.drawLine_arrow(itemignoreZooming=False)

def handleCollisions(compartments, moveCallback, layoutPt,margin = 5.0):
    
    if len(compartments) is 0 : return
    compartments = sorted(compartments, key = lambda c: c.sceneBoundingRect().center().x())
    reference = compartments.pop(0);
    print reference.name
    referenceRect = reference.sceneBoundingRect()
    colliders = filter( lambda compartment : referenceRect.intersects(compartment.sceneBoundingRect())
                      , compartments
                      )
    for collider in colliders:
        moveCallback(reference, collider, layoutPt,margin)
    return handleCollisions(compartments, moveCallback, layoutPt,margin)