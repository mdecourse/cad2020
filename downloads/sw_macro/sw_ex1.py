import pythoncom
import win32com.client
import win32api
# GetMassProperties( ((3, 1), (16387, 3)))

arg1 = win32com.client.VARIANT(pythoncom.VT_I4, 1)
arg2 = win32com.client.VARIANT(pythoncom.VT_I4|pythoncom.VT_BYREF, 3)


app=win32com.client.Dispatch("SldWorks.Application")
doc=app.OpenDoc("c:\\tmp\\sw_macro\\block.SLDPRT", 1)
doc.SaveAs2("c:\\tmp\\sw_macro\\block.stl", 0, True, False)
#https://blog.csdn.net/zengqh0314/article/details/102508781
volumn = doc.Extension.GetMassProperties(arg1, arg2)
print(volumn[3]*1000*1000*1000, "mm*3")
'''
e_msg = win32api.FormatMessage(-2147352571)
print(e_msg)
'''
