import pythoncom
import win32com.client
import win32api
# GetMassProperties( ((3, 1), (16387, 3)))
arg1 = win32com.client.VARIANT(pythoncom.VT_I4, 1)
arg2 = win32com.client.VARIANT(pythoncom.VT_I4, -1)

app=win32com.client.Dispatch("SldWorks.Application")
doc=app.OpenDoc("c:\\tmp\\sw_macro\\block2.SLDPRT", 1)
doc.SaveAs2("c:\\tmp\\sw_macro\\block2.stl", 0, True, False)
#SelectByID2((8, 1), (8, 1), (5, 1), (5, 1), (5, 1), (11, 1), (3, 1), (9, 1), (3, 1))
arg3 = win32com.client.VARIANT(pythoncom.VT_BSTR, "Sketch1")
arg4 = win32com.client.VARIANT(pythoncom.VT_BSTR, "SKETCH")
arg5 = win32com.client.VARIANT(pythoncom.VT_R8, 0)
arg6 = win32com.client.VARIANT(pythoncom.VT_R8, 0)
arg7 = win32com.client.VARIANT(pythoncom.VT_R8, 0)
arg8 = win32com.client.VARIANT(pythoncom.VT_BOOL, False)
arg9 = win32com.client.VARIANT(pythoncom.VT_I4, 0)
arg10 = win32com.client.VARIANT(pythoncom.VT_DISPATCH, None)
arg11 = win32com.client.VARIANT(pythoncom.VT_I4, 0)
# 先選擇 Sketch1
status = doc.Extension.SelectByID2(arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
# 再選擇 DIMENSION
arg12 = win32com.client.VARIANT(pythoncom.VT_BSTR, "Width@Sketch1@block2.SLDPRT")
arg13 = win32com.client.VARIANT(pythoncom.VT_BSTR, "DIMENSION")
status = doc.Extension.SelectByID2(arg12, arg13, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
#Dim swDimension As SldWorks.Dimension
swDimension = doc.Parameter("Width@Sketch1")
# 單位為 m
swDimension.SystemValue = 0.5
sel = doc.ClearSelection2 
sel = True
status = doc.EditRebuild()
arg31 = win32com.client.VARIANT(pythoncom.VT_I4, 1)
arg32 = win32com.client.VARIANT(pythoncom.VT_I4|pythoncom.VT_BYREF, 3)
volumn = doc.Extension.GetMassProperties(arg31, arg32)
print(volumn[3]*1000*1000*1000, "mm*3")
doc.SaveAs2("c:\\tmp\\sw_macro\\block3.SLDPRT", 0, True, False)
