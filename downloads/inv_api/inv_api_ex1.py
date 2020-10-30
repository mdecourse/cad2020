import pythoncom
import win32com.client
import win32api
import os

# Open Inventor
invApp = win32com.client.Dispatch("Inventor.Application")
#print(invApp)
invApp.Visible = True

invApp.SilentOperation = True

# Set location of assembly
partName = 'C:/tmp/Part1.ipt'

# Open the model
oDoc = invApp.Documents.Open(partName)
# use UserParameters to access the user parameters
#oUserParams = oDoc.ComponentDefinition.Parameters.UserParameters
#oNewParam = oUserParams.AddByExpression("x", "9", "mm")
# use Item() to get the model parameter named "d0"
d0 = oDoc.ComponentDefinition.Parameters.Item("d0")
# Expression can add dimension unit
#d0.Expression = "2 cm"
# Value use the default system unit: cm
d0.Value = 2
# use Update() method to get the new part volume
oDoc.Update()
# fit the active view and save the part image
invApp.ActiveView.Fit(True)
oDoc.SaveAs("C:/tmp/Part1.png", True)
print(oDoc.ComponentDefinition.MassProperties.Volume)
#invApp.Quit()