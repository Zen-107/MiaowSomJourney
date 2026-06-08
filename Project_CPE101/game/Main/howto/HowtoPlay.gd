extends Node2D

func _ready() -> void: #เพิ่มรูปที่เกี่ยวข้อง แก้ comment อาจจะไม่ต้องแต่ทำก็ดี
	im_node =[$Platu,$Hintbt,$Blocko,$Hint1,$Salmon,$Map1,$Montall,$Montall,$BossAll,$Object,$Obmap,$Salmon,$Creatbt]
	start_HowtoPlay()
	
func _on_backbt_pressed() : #เชื่อมปุ่มไปหน้า main menu
	#pass
	get_tree().change_scene_to_file("res://game/Main/mainmenu/main.tscn")

func start_HowtoPlay():
	print("เริ่มหน้า How To Play และเริ่มฟังชั่น hide_some และ set_ScalePosition  ")
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
	$NameS.size=Vector2(155, 44)
	$"Text-next".size=Vector2(164, 44)
	$Carrot.scale=Vector2(0.5,0.5)
	$Carrot.position =Vector2(555,362)
			#text How To Play ใหญ่
	$"Title-Text".scale =Vector2(1,1)#set scale ( ขนาดใหญ่ )
	$"Title-Text".position =Vector2(224,165) #set position ( กลางจอ  )
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
	$"Title-Text".scale =Vector2(0.2,0.2) #ย่อขนาดฟ้อน How To Play ที่ตอนแรกตัวใหญ่
	$"Title-Text".position =Vector2(980,22) #ย่อเสร็จละย้ายไป มุมจอ
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
	$"Next-bt".text="มาแล้วหรอ! กำลังรออยู่เลย คงอยากจะรู้วิธีเล่นสินะ"
	$"Back-bt".show() #[Back] (ปุ่มกลับไปหน้า Menu)
	$"Skip-bt".show() #[Skip] (ปุ่มข้ามเนื้อเรื่องแล้ว show HowtoPlay ทั้งหมดแบบสรุป) 
	$"Next-bt".show() #[Next] (ปุ่มกดเฉยๆ เพื่อไปบทพูดต่อไป)
	$NameS.show()
	$"Text-next".show()
	
var dia_all=["อย่างที่รู้กันว่าตอนนี้เจ้าหญิงปลาทูได้ถูกจับตัวไป ดังนั้นเราจึงต้องหาทางไปช่วยให้ได้!",#1platu
	"เริ่มแรกข้าจะให้ Hint ซึ่งเป็นรหัสที่บอกเส้นทางเชื่อมต่อสำหรับที่ต่างๆไปนะ", #2HintBt
	"เดี๋ยวพอเจ้าออกไปก็คงเจอกับนักวาดแผนที่ เขาจะช่วยเหลือเจ้าเรื่องแปลงรหัสนั้นเป็นแผนที่เอง!",#3blocko
	"จริงๆก็ไม่ยากมากหรอก ความหมายของรหัสคือ 1 = มีเส้นทาง และ 0 = ไม่มีเส้นทาง", #4matrixngraph
	"แต่ป้องกันไว้ก่อน จนกว่าจะออกเดินทางอย่าให้ข้อมูลรั่วไหลล่ะ ไม่งั้นพวกศัตรูมันจะรู้ตัวซะก่อน", #5nothing
	"ตอนออกเดินทางสิ่งที่เจ้าต้องทำคือ เลือกเดิน เพื่อไปช่วยเจ้าหญิง", #6map1/2/3
	"ระหว่างทาง เจ้าอาจจะต้องสู้กับปีศาจโดยไม่รู้ตัว เรื่องนี้ก็โชคไม่ดีล่ะนะ", #7mon1
	"ปีศาจเองก็มีหลายระดับ พวกตัวเล็กๆ มันไม่คะนามือเจ้าอยู่แล้ว ...แต่ตัวหัวหน้ามันเนี่ยสิ...",#8allmon3
	"กีกี้ บั่วบั้ว หนุ่ยนุ้ย เจ้า 3 ตัวนี้สามารถทำให้เจ้าเสียพลังชีวิตได้ 2 รอบในทีเดียวเลย",#9allboss
	"แต่ข้าแอบเอาอุปกรณ์บางส่วนที่พอจะช่วยเจ้าได้ไปแอบไว้แล้วล่ะ ข้าอยากให้เจ้าไปตามหามันก่อน",#10object
	"อยากให้หาจนครบเลย ถึงจะไม่ได้ใช้งานแต่เก็บกลับมาด้วยก็จะดีมากๆ",#11leavenode+circle
	"แน่นอนว่าถ้าเจ้าได้เก็บมาใช้ มันก็มีแต่ประโยชน์กับเจ้านะ!",#12
	"โหมดหลักก็มีแค่นี้แหละ หลังจากเดินทางถ้าเจ้าอยากไปลองเขียนแผนที่ ข้าจะฝากฝังให้!"] #13modecreate
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
	$"Next-bt".text = ("กลับหน้าเมนูเถอะ ไม่มีไรละ ")
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
