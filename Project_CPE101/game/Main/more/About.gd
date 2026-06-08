extends Node2D

func _ready() -> void: #เพิ่มรูปที่เกี่ยวข้อง แก้ comment อาจจะไม่ต้องแต่ทำก็ดี
	im_node =[$Th2,$Hint1,$Hintmap,$Am41,$Thdfs1,$Dfs2,$Monst1,$Subtree1,$Spanns1,$Spanns1,$Monst1,$BossAll,$Salmon]
	start_About()
	
func _on_backbt_pressed() : #เชื่อมปุ่มไปหน้า main menu
	#pass
	get_tree().change_scene_to_file("res://game/Main/mainmenu/main.tscn")
	
func start_About():
	print("เริ่มหน้า About และเริ่มฟังชั่น hide_some และ set_ScalePosition  ")
	hide_some() #hide เกือบทุกอัน show แค่ Title กับพื้นหลัง ตอนเริ่ม
	set_ScalePosition()#set scale and position ก่อนเริ่ม
	print("set scale เรียบร้อย เริ่มปรับตัวอักษร")
	print("delay นิดนึง")
	$wait.start()#หน่วงเวลา 1.75s แล้วไปที่ [_on_wait_timeout()]
	
func hide_some(): #หลังกดปุ่มเปิดหน้า
	$ABnHtPbg.show() #[พื้นหลัง]
	$Carrot.hide() #[Character1]
	$"Title-Text".show() #[Title-Text]
	$"Back-bt".hide() #[Back] (ปุ่มกลับไปหน้า Menu)
	$"Skip-bt".hide() #[Skip] (ปุ่มข้ามเนื้อเรื่องแล้ว show HowtoPlay ทั้งหมดแบบสรุป) 
	$"Next-bt".hide() #[Next] (ปุ่มกดเฉยๆ เพื่อไปบทพูดต่อไป)
	$NameS.hide()
	$"Text-next".hide()
	$"Rest-bt".hide()
	for sprite in im_node:
		sprite.hide()
	
func set_ScalePosition():
			#Character+name+text in next-bt
	$NameS.position=Vector2(44, 409)
	$"Text-next".position=Vector2(997, 589)
	$NameS.size=Vector2(200, 50)
	$"Text-next".size=Vector2(300, 50)
	$Carrot.scale=Vector2(0.5,0.5)
	$Salmon.scale=Vector2(0.5,0.5)
	$Salmon.position=Vector2(300,335)
	$Carrot.position =Vector2(555,362)
			#text How To Play ใหญ่
	$"Title-Text".scale =Vector2(1,1)#set scale ( ขนาดใหญ่ )
	$"Title-Text".position =Vector2(195,165) #set position ( กลางจอ )
			#ปุ่ม Back
	$"Back-bt".position=Vector2(28,28)
	$"Back-bt".size=Vector2(181,59)
			#ปุ่ม Skip & Next
	$"Skip-bt".size=Vector2(54, 51)
	$"Skip-bt".position=Vector2(22, 585)
	$"Rest-bt".size=Vector2(54, 51)
	$"Rest-bt".position=Vector2(22, 585)
	$"Next-bt".size=Vector2(1106, 239)
	$"Next-bt".position=Vector2(24, 393)
	
func _on_wait_timeout():
	print("ย้ายที่และปรับ scale Title-Text")
	$"Title-Text".scale =Vector2(0.2,0.2) #ย่อขนาดฟ้อน About this App ที่ตอนแรกตัวใหญ่
	$"Title-Text".position =Vector2(965,22) #ย่อเสร็จละย้ายไป มุมจอ
	print("Show Carrot")
	$Carrot.show()
	print("delay นิดนึง")
	$wait2.start()
func _on_wait_2_timeout():
	print("ย้าย Carrot")
	$Carrot.position =Vector2(840,335)
	start_Story()

func start_Story():
	dianum=0
	for sprite in im_node:
		sprite.hide()
	print("เริ่มบทพูด แรก")
	$"Text-next".position=Vector2(997, 589)
	$"Text-next".text=("...กดเพื่อไปต่อ...")
	$"Rest-bt".hide()
	$"Next-bt".text="มาแล้วหรอ! กำลังรออยู่เลย คงอยากจะรู้เกี่ยวกับแอปนี้สินะ"
	$"Back-bt".show() #[Back] (ปุ่มกลับไปหน้า Menu)
	$"Skip-bt".show() #[Skip] (ปุ่มข้ามเนื้อเรื่องแล้ว show HowtoPlay ทั้งหมดแบบสรุป) 
	$"Next-bt".show() #[Next] (ปุ่มกดเฉยๆ เพื่อไปบทพูดต่อไป)
	$NameS.show()
	$"Text-next".show()
	
var dia_all=["ขอบอกไว้ก่อนว่ากระบวนการและหลักการต่างๆของเกมนี้ ประยุกต์มาจากบทเรียนล่ะ!",#1platu
	"เริ่มแรก Hint ซึ่งเป็นรหัสที่บอกเส้นทางเชื่อมต่อสำหรับที่ต่างๆน่ะ มันคือ Adjacency Matrix", #2HintBt
	"และการแปลงรหัสนั้นเป็นแผนที่ ก็คือการเขียนในรูปแบบของ Graph นั่นเอง!",#3blocko
	"ด้วยความที่เป็น Undirected Connected Simple Graph จึงมีแค่เลข 1 กับ 0", #4matrixngraph
	"ต่อมาคือ การออกเดินทาง หลักการที่เราใช้คือ Depht-First Search (DFS)", #5 noting
	"มันคือการเลือกทางเดินแล้วไปให้ถึงความลึกที่ลึกที่สุดก่อน แล้วจึงจะกลับไปที่ทางแยก", #6map1/2/3
	"ในตอนจบเกม จะเห็นว่ามีคะแนนการสำรวจและ สรุปเส้นทางให้ใช่มั้ยล่ะ", #7mon1
	"การสรุปเส้นทางก็คือ Subgraph ในรูป Tree ถ้ามีครบทุกจุดมันก็คือ Spanning tree",#8allmon3
	"Graph อันเดียวกันก็มี Spanning tree แตกต่างกันได้หลายแบบเลย",#9allboss
	"เพราะแบบนั้นจึงอยากให้สำรวจจนครบทุกจุด 100% เราจะได้มาดู Spanning tree กัน",#10object
	"ในส่วนของนักวาดแผนที่คือการใส่ Adjacency Matrix และแปลงเป็น Graph ลองไปกดๆดูนะ",#11leavenode+circle
	"สุดท้ายนี้ขอขอบคุณที่มาร่วมเล่นเกมของเรา! อนาคตอาจจะมีการพัฒมากขึ้นไปอีก",#12
	"ถ้ามีข้อผิดพลาดประการใด ก็ขออภัยด้วย"] #13modecreate
	#13บทพูด
var im_node: Array=[]
var dianum=0

func _on_nextbt_pressed():
	for sprite in im_node:
		sprite.hide()
	if dianum < dia_all.size():
		$"Next-bt".text = dia_all[dianum]
		im_node[dianum].show()
		dianum+=1
	else: elonskip()
func elonskip():
	$"Text-next".position=Vector2(905,589)
	$"Text-next".text=("<<--กด Repeat เพื่อเริ่มใหม่")
	$"Next-bt".text = ("แล้วเจอกันใหม่ในโปรเจคหน้า!")
	dianum=14
	$"Skip-bt".hide()
	$"Rest-bt".show()
	
func _on_skipbt_pressed():
	$"Text-next".position=Vector2(905,589)
	$"Text-next".text=("<<--กด Repeat เพื่อเริ่มใหม่")
	$"Next-bt".text = ("ข้ามเนื้อเรื่องแล้ว")
	dianum=14
	$"Skip-bt".hide()
	$"Rest-bt".show()
	for sprite in im_node:
		sprite.hide()

func _on_restbt_pressed():
	start_Story()
