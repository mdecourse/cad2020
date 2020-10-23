import pythoncom
import win32com.client
import win32api
import os
'''
os.system("taskkill /IM sldworks.exe /F")
os.system("taskkill /IM sldworks_fs.exe /F")
'''
'''
About DispatchEx and Dispatch Methods:
https://stackoverflow.com/questions/18648933/using-pywin32-what-is-the-difference-between-dispatch-and-dispatchex
Source code:
http://pywin32.hg.sourceforge.net/hgweb/pywin32/pywin32/file/0db1b26904d5/com/win32com/src/PyIDispatch.cpp
Doc:
https://docs.microsoft.com/en-us/dotnet/standard/native-interop/com-callable-wrapper

IDispatch: Provides a mechanism for late binding to type.
IDispatchEx:
    Interface supplied by the runtime if the class implements IExpando. The IDispatchEx interface is an extension of the IDispatch interface that, unlike IDispatch, enables enumeration, addition, deletion, and case-sensitive calling of members.
'''
app = win32com.client.DispatchEx("SldWorks.Application")
#app=win32com.client.Dispatch("SldWorks.Application")

# define var to convert variables
def var(type, value):
    # type needs to be string
    # use builtin getattr() to return pythoncom.type
    pytype = getattr(pythoncom, type)
    return win32com.client.VARIANT(pytype, value)

# for two-type variable convert
# is there any three-type variant?
def var2(type1, type2, value):
    pytype1 = getattr(pythoncom, type1)
    pytype2 = getattr(pythoncom, type2)
    return win32com.client.VARIANT(pytype1|pytype2, value)
    
def part(app, fileName, sketchName, dimName, newDim, newFileName):
    arg1 = var("VT_I4", 1)
    # GetMassProperties( ((3, 1), (16387, 3)))
    #arg1 = win32com.client.VARIANT(pythoncom.VT_I4, 1)
    arg2 = var("VT_I4", -1)

    # 0. need the most important obj app
    #app=win32com.client.Dispatch("SldWorks.Application")
    # use relative directory to open part
    # 1. open part file, need the path of the part file (need the file name)
    #doc=app.OpenDoc(".\\block2.SLDPRT", 1)
    doc=app.OpenDoc(os.path.join(os.getcwd(), fileName), 1)
    # save part as binary stl
    # can we save part as ASCII stl as well?
    #doc.SaveAs2(".\\block2.stl", 0, True, False)
    # the parameter VARIANT list for SelectByID2
    # can we automate the VARIANT conversion?
    # 2. use the sketch to select the SKETCH (need the sketch name)
    #SelectByID2((8, 1), (8, 1), (5, 1), (5, 1), (5, 1), (11, 1), (3, 1), (9, 1), (3, 1))
    #arg3 = var("VT_BSTR", "Sketch1")
    arg3 = var("VT_BSTR", sketchName)
    arg4 = var("VT_BSTR", "SKETCH")
    arg5 = var("VT_R8", 0)
    arg6 = var("VT_R8", 0)
    arg7 = var("VT_R8", 0)
    arg8 = var("VT_BOOL", False)
    arg9 = var("VT_I4", 0)
    arg10 = var("VT_DISPATCH", None)
    arg11 = var("VT_I4", 0)
    # select Sketch1 first
    status = doc.Extension.SelectByID2(arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    # select DIMENSION to to modify
    # 3. use the dimension name @ sketch name @ part file name
    # to select the DIMENSION to modify
    #arg12 = var("VT_BSTR", "Width@Sketch1@block2.SLDPRT")
    arg12 = var("VT_BSTR", dimName+"@"+sketchName+"@"+fileName)
    arg13 = var("VT_BSTR", "DIMENSION")
    status = doc.Extension.SelectByID2(arg12, arg13, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    #Dim swDimension As SldWorks.Dimension
    # 4. to bring out the parameter to modify, need the dimension name and 
    # sketch name
    #swDimension = doc.Parameter("Width@Sketch1")
    swDimension = doc.Parameter(dimName+"@"+sketchName)
    # the dimension unit is in meter
    # 5. need the new value of the parameter
    #swDimension.SystemValue = 0.50
    swDimension.SystemValue = newDim
    # 6. do the final house keeping process, clear selection and rebuild the part
    sel = doc.ClearSelection2 
    sel = True
    status = doc.EditRebuild()
    arg31 = var("VT_I4", 1)
    arg32 = var2("VT_I4", "VT_BYREF", 3)
    # 7. get the volume of the new part
    volumn = doc.Extension.GetMassProperties(arg31, arg32)
    #print(volumn[3]*1E9, "mm*3")
    # 8. save the new part (need the new part file name)
    #doc.SaveAs2(".\\block3.SLDPRT", 0, True, False)
    doc.SaveAs2(os.path.join(os.getcwd(), "html/" + newFileName + ".SLDPRT"), 0, True, False)
    # save jpg of part
    doc.EditRebuild()
    arg33 = var("VT_BSTR", "Isometric")
    doc.ShowNamedView(arg33)
    doc.ViewZoomtofit2()
    doc.SaveAs3(os.path.join(os.getcwd(), "html/" + newFileName + ".jpg"), 0, 0)
    # mm*3
    return str(round(volumn[3]*1E9, 3)) + " mm*3"
html = "以下零件採 SolidWorks 2017 SP 2.0 教育版繪製:<br /><br /><table border='1' cellpadding='5'><tr><th>Number</th><th>Part</th><th>Jpg</th><th>Width</th><th>Volume</th></tr>"
index = 0
for i in range(1, 11):
    dim = i*0.002
    blockVolume = part(app, "31_step.SLDPRT", "Sketch1", "Width", dim, "31_" + str(i))
    print("31_" + str(i) + ".SLDPRT, dim= " + str(round(dim, 3)) +", volume= " + blockVolume)
    index += 1
    newFileName = "31_" + str(i)
    html += '''<tr>
    <td>''' + str(index) +'''</td>
    <td><a href="/downloads/sw_macro/html/''' + newFileName + '''.SLDPRT">''' + newFileName + '''.SLDPRT</a></td>
    <td><img width="300" src="/downloads/sw_macro/html/''' + newFileName + '''.jpg"></img></td>
    <td>''' + str(round(dim*1000, 2)) + ''' mm </td>
    <td>''' + blockVolume + '''</td>
    </tr>
    '''
html += "</table>"
# save part.html
with open("./html/part.html", "w", encoding="utf-8") as f:
     f.write(html)

app.ExitApp()

'''
for assembly
        swModelDocExt.SelectByID2("", "EDGE", -0.439825991092107, 7.07350481263802E-02, 0.40982045578545, true, 2, null, 0);
        swModelDocExt.SelectByID2("", "EDGE", -0.219003008311574, 0.073085842475507, 0.549481823985616, true, 4, null, 0);
        swModelDocExt.SelectByID2("Part-3@AssemModel", "COMPONENT", 0, 0, 0, true, 1, null, 0);
        swFeature = (Feature)swFeatureManager.FeatureLinearPattern2(3, 40 / 1000, 0, 0, false, true, "NULL", "NULL", false);
        assemblyModel.ClearSelection2(true);
'''
'''
os.system("taskkill /IM sldworks.exe /F")
os.system("taskkill /IM sldworks_fs.exe /F")
# now the SolidWorks is embedding
'''