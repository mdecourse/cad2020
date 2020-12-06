# nx_open_part.py
# 導入 NXOpen
import NXOpen
import NXOpen.UF
 
def main():
    # 取得目前開啟的工作階段
    theSession = NXOpen.Session.GetSession()
    theUfSession = NXOpen.UF.UFSession.GetUFSession()
    # 建立 ListingWindow
    listWin= theSession.ListingWindow
    # 開啟零件檔案
    basePart1 = theSession.Parts.OpenBaseDisplay("c:/tmp/block.prt")
    workPart = theSession.Parts.Work
    unit1 = workPart.UnitCollection.FindObject("MilliMeter")
    # height
    p7 = workPart.Expressions.FindObject("p7")
    # width
    p8 = workPart.Expressions.FindObject("p8")
    # length
    p9 = workPart.Expressions.FindObject("p9")
    workPart.Expressions.EditWithUnits(p7, unit1, "30")
    workPart.Expressions.EditWithUnits(p8, unit1, "60")
    workPart.Expressions.EditWithUnits(p9, unit1, "90")
    theSession.UpdateManager.DoUpdate(0)
    #saveStatus1 = workPart.SaveAs("c:/tmp/block_new.prt")
    #saveStatus1.Dispose()
    # initialize list to hold bodies
    theBodyTags = []
 
    for x in theSession.Parts.Work.Bodies:
        if x.IsSolidBody:
            theBodyTags.append(x.Tag)
 
    # 開啟所建立的 ListingWindow
    listWin.Open()
    listWin.WriteLine("number of solid bodies: " + str(len(theBodyTags)))
 
    (massProps, Stats) = theUfSession.Modeling.AskMassProps3d(theBodyTags, len(theBodyTags), 1, 4, .03, 1, [0.99,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0])
    listWin.WriteLine("units: kg, mm")
    listWin.WriteLine("surface area: " + str(massProps[0]))
    listWin.WriteLine("volume: " + str(massProps[1]*1E9))
    '''
    listWin.WriteLine(str(NXOpen.MeasureBodies.Volume))
    myMeasure = theSession.Parts.Display.MeasureManager
    massUnits1 = theSession.Parts.Display.UnitCollection.GetBase("Area")
    massUnits2 = theSession.Parts.Display.UnitCollection.GetBase("Volume")
    massUnits3 = theSession.Parts.Display.UnitCollection.GetBase("Mass")
    massUnits4 = theSession.Parts.Display.UnitCollection.GetBase("Length")
    massUnits = [massUnits1, massUnits2, massUnits3, massUnits4]
    mb = myMeasure.NewMassProperties(massUnits, 0.99, theSession.Parts.Work.Bodies)
    mb.InformationUnit = NXOpen.MeasureBodies.AnalysisUnit.KILOGRAMMILLIMETER 

    listWin.WriteLine("volume: " + str(mb.Volume) + " mm^3")
    '''
    # 在 ListingWindow 中寫入字串
    listWin.WriteLine("Hello, NXOpen")
    listWin.Close()
    
if __name__ == "__main__":
    main()
    
'''
https://docs.plm.automation.siemens.com/data_services/resources/nx/12/nx_api/custom/en_US/ugopen_doc/uf_modl/global.html#UF_MODL_ask_mass_props_3d
import NXOpen
import NXOpen.UF
 
theSession = NXOpen.Session.GetSession()
theLw = theSession.ListingWindow
theUfSession = NXOpen.UF.UFSession.GetUFSession()    
 
def main(): 
 
    workPart = theSession.Parts.Work
    displayPart = theSession.Parts.Display
 
    markId1 = theSession.SetUndoMark(NXOpen.Session.MarkVisibility.Visible, "mass props 3D")
    theLw.Open()
 
    # initialize list to hold bodies
    theBodyTags = []
 
    for x in theSession.Parts.Work.Bodies:
        if x.IsSolidBody:
            theBodyTags.append(x.Tag)
 
    # debug
    theLw.WriteLine("number of solid bodies: " + str(len(theBodyTags)))
 
    #units: pound inch
    (massProps, Stats) = theUfSession.Modeling.AskMassProps3d(theBodyTags, len(theBodyTags), 1, 1, .03, 1, [0.99,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0])
    theLw.WriteLine("units: pound, inch")
    theLw.WriteLine("surface area: " + str(massProps[0]))
    theLw.WriteLine("volume: " + str(massProps[1]))
    theLw.WriteLine("mass: " + str(massProps[2]))
    theLw.WriteLine("center of mass (WCS): " + str(massProps[3]) + ", " + str(massProps[4]) + ", " + str(massProps[5]))
    theLw.WriteLine("first moments (centroidal): " + str(massProps[6]) + ", " + str(massProps[7]) + ", " + str(massProps[8]))
    theLw.WriteLine("moments of inertia (WCS): " + str(massProps[9]) + ", " + str(massProps[10]) + ", " + str(massProps[11]))
    theLw.WriteLine("moments of inertia (centroidal): " + str(massProps[12]) + ", " + str(massProps[13]) + ", " + str(massProps[14]))
    theLw.WriteLine("spherical moment of inertia: " + str(massProps[15]))
    theLw.WriteLine("inertia products (WCS): " + str(massProps[16]) + ", " + str(massProps[17]) + ", " + str(massProps[18]))
    theLw.WriteLine("inertia products (centroidal): " + str(massProps[19]) + ", " + str(massProps[20]) + ", " + str(massProps[21]))
    theLw.WriteLine("prinicpal axes (WCS): [" + str(massProps[22]) + ", " + str(massProps[23]) + ", " + str(massProps[24]) + "] [" + str(massProps[25]) + ", " + str(massProps[26]) + ", " + str(massProps[27]) + "] [" + str(massProps[28]) + ", " + str(massProps[29]) + ", " + str(massProps[30]) + "]")
    theLw.WriteLine("principal moments (centroidal): " + str(massProps[31]) + ", " + str(massProps[32]) + ", " + str(massProps[33]))
    theLw.WriteLine("radii of gyration (WCS): " + str(massProps[34]) + ", " + str(massProps[35]) + ", " + str(massProps[36]))
    theLw.WriteLine("radii of gyration (centroidal): " + str(massProps[37]) + ", " + str(massProps[38]) + ", " + str(massProps[39]))
    theLw.WriteLine("spherical radius of gyration: " + str(massProps[40]))
    theLw.WriteLine("density: " + str(massProps[46]))
 
    theLw.Close()
 
if __name__ == '__main__':
    main()
'''



