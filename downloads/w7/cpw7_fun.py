import pythoncom
import win32com.client
import win32api
import os
 
# Open Inventor
invApp = win32com.client.Dispatch("Inventor.Application")
#print(invApp)

# partName with .ipt extension
# newPartName without extension
def invPart(app, vis, partName, dimName, newExp, newPartName):
    #invApp.Visible = False
    app.Visible = vis
     
    invApp.SilentOperation = True
     
    # Set location of assembly
    #partName = 'C:/tmp/cadw7/Part1.ipt'
     
    # Open the model
    oDoc = app.Documents.Open(os.path.join(os.getcwd(), partName))
    # use UserParameters to access the user parameters
    #oUserParams = oDoc.ComponentDefinition.Parameters.UserParameters
    #oNewParam = oUserParams.AddByExpression("x", "9", "mm")
    # use Item() to get the model parameter named "d0"
    #d0 = oDoc.ComponentDefinition.Parameters.Item("d0")
    d0 = oDoc.ComponentDefinition.Parameters.Item(dimName)
    # Expression can add dimension unit
    #d0.Expression = "2 cm"
    d0.Expression = newExp
    # Value use the default system unit: cm
    #d0.Value = 1
    # use Update() method to get the new part volume
    oDoc.Update()
    # fit the active view and save the part image
    app.ActiveView.Fit(True)
    #oDoc.SaveAs("C:/tmp/cadw7/Part1.png", True)
    oDoc.SaveAs(os.path.join(os.getcwd(), newPartName + ".ipt"), True)
    oDoc.SaveAs(os.path.join(os.getcwd(), newPartName + ".png"), True)
    #print(oDoc.ComponentDefinition.MassProperties.Volume)
    volume = oDoc.ComponentDefinition.MassProperties.Volume
    #invApp.Quit()
    return volume

for i in range(1, 10):
    volume = invPart(invApp, True, "3204_01.ipt", "d0", str(i*1) +" cm", "3204_01_"+ str(i))
    print(volume)

