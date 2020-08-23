'''
根據評分表單中的 自評分數, 互評得分, 教師評分, 計算學員課程成績
'''
 
def diff(分數1, 分數2):
    return abs(分數1 - 分數2)
     
def getHigh(分數1, 分數2):
    if  分數1 > 分數2:
        return 分數1
    else:
        return 分數2

def getLow(分數1, 分數2):
    if  分數1 < 分數2:
        return 分數1
    else:
        return 分數2
 
def 分組評分(自評分數, 教師評分):
    return getLow(自評分數, 教師評分)
    if diff(自評分數, 教師評分) > 5:
        return getLow(自評分數, 教師評分)
    else:
        return int(自評分數*0.4 + 教師評分*0.6)
     
def 全班比分(互評得分, 分組評分):
    if diff(互評得分, 分組評分) < 5:
        學員成績 = getHigh(互評得分, 分組評分)
    else:
        學員成績 = int(互評得分*0.4 + 分組評分*0.6)
    return 學員成績
 
def 學員成績(自評分數, 互評得分, 教師評分):
    學員課程成績 = 全班比分(互評得分, 分組評分(自評分數, 教師評分))
    return 學員課程成績
    
for i in range(10):
    self_score = 50 + i*5
    for j in range(10):
        peer_score = 50 + j*5
        for k in range(10):
            teacher_score = 50 + k*5
            print(self_score, peer_score, teacher_score, "=", 學員成績(self_score, peer_score, teacher_score))