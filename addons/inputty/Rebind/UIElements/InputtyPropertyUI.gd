extends Control
class_name InputtyPropertyUI

@export var propertyName :StringName= ""

var customProperty:InputtyProperty

func _ready():
	$PropertyLabel.text = propertyName
	
	if customProperty is InputtyPropertyBool:
		$BoolUI.visible = true
		displayBoolVal()
	if customProperty is InputtyPropertyFloat:
		$FloatUI.visible = true
		displayFloatVal()
	if customProperty is InputtyPropertyEnum:
		$EnumUI.visible = true
		for v in customProperty.values:
			$EnumUI/OptionButton.add_item(v)
		displayEnumValue()

func toggleVal():
	customProperty.value = !customProperty.value
	displayBoolVal()
	Inputty._inputRemap.unsavedChanges = true
	
func displayBoolVal():
	if customProperty.value==true:
		$BoolUI/Button.text = customProperty.trueDisplay
	else:
		$BoolUI/Button.text = customProperty.falseDisplay

var initSet:bool = false
func floatValueChanged(value):
	if !initSet:
		initSet = true
		return
	customProperty.value = value
	displayFloatVal()
	Inputty._inputRemap.unsavedChanges = true
	
func displayFloatVal():
	$FloatUI/HSlider.min_value = customProperty.minVal
	$FloatUI/HSlider.max_value = customProperty.maxVal
	if $FloatUI/HSlider.value!=customProperty.value:
		$FloatUI/HSlider.value = customProperty.value
	
	$FloatUI/ValueDisplay.text = str(snapped(customProperty.value,0.01))

func setEnumValue(i:int):
	customProperty.valueIndex = i
	displayEnumValue()
	Inputty._inputRemap.unsavedChanges = true
	
func displayEnumValue():
	$EnumUI/OptionButton.select(customProperty.valueIndex)

