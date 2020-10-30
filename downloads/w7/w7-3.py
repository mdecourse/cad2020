import win32com.client
from win32com.client import gencache, Dispatch, constants, DispatchEx

oApp = win32com.client.Dispatch('Inventor.Application')
oApp.Visible = True
mod = gencache.EnsureModule('{D98A091D-3A0F-4C3E-B36E-61F62068D488}', 0, 1, 0)
oApp = mod.Application(oApp)
# oApp.SilentOperation = True
oDoc = oApp.ActiveDocument
oDoc = mod.PartDocument(oDoc)
#in case of an assembly use the following line instead
#oDoc = mod.AssemblyDocument(oDoc)
prop = oApp.ActiveDocument.PropertySets.Item("Design Tracking Properties")

# getting description and designer from iproperties
Descrip = prop('Description').Value
Designer = prop('Designer').Value
print("Description: ",Descrip)
print("Designer: ",Designer)

# getting mass and area
MassProps = oDoc.ComponentDefinition.MassProperties
#area of part
dArea = MassProps.Area
print("area: ",dArea)
#mass
mass = MassProps.Mass
print("mass: ",mass)

#getting  parameters
oParams = oDoc.ComponentDefinition.Parameters
lNum = oParams.Count
print("number of Parameters: ",lNum)
# make sure the parameter names exist in the Inventor model
param_d0 = oParams.Item("d0").Value
print("Parameter d0: ",param_d0)
param_d1 = oParams.Item("d1").Value
print("Parameter d1: ",param_d1)
param_d2 = oParams.Item("d2").Value
print("Parameter d2: ",param_d2)
param_d0_exp = oParams.Item("d0").Expression
print("Parameter d0_exp: ",param_d0_exp)
param_d1_exp = oParams.Item("d1").Expression
print("Parameter d1_exp: ",param_d1_exp)
param_d2_exp = oParams.Item("d2").Expression
print("Parameter d2_exp: ",param_d2_exp)