class_name FuzzyAutocompleteService extends AutocompleteService

## This will define how far away an entry can be defined by the Damerau-Levenshtein distance calculation
@export var max_allowed_distance: int = 10

class FuzzyResult:
	var result: StrippedCommand
	var distance: int

	func _init(command: StrippedCommand, calculated_distance: int):
		result = command
		distance = calculated_distance

class FlattenIntArray:
	var data: Array[int] = []
	var width: int

	func _init(target_width: int, height: int):
		width = target_width
		var entries = width * height
		for i in entries:
			data.append(0)

	func get_value(x: int, y: int):
		return data[_get_flatten_position(x, y)]

	func _get_flatten_position(x: int, y: int) -> int:
		return y * width + x

	func set_data(new_data: int, x: int, y: int):
		data[_get_flatten_position(x, y)] = new_data

func search_autocomplete(typed: String) -> Array[StrippedCommand]:
	var result_set: Array[FuzzyResult] = []
	for possible_command in Console._get_autocomplete_commands():
		var distance: int = _calculate_distance(typed, possible_command.command)
		if distance >= max_allowed_distance:
			continue
		result_set.append(FuzzyResult.new(possible_command, distance))

	result_set.sort_custom(_distance_sort)
	var return_data: Array[StrippedCommand]
	for data in result_set:
		return_data.append(data.result)

	return return_data

func _calculate_distance(search: String, source: String) -> int:
	var length_a: int = search.length()
	var length_b: int = source.length()
	if length_a == 0 or length_b == 0:
		return 100000

	var matrix: FlattenIntArray = FlattenIntArray.new(length_a, length_b)

	for i in length_a:
		matrix.set_data(i, i, 0)

	for j in length_b:
		matrix.set_data(j, 0, j)

	for i in range(1, length_a):
		for j in range(1, length_b):
			var cost: int = 0
			if search[i - 1] != source[j - 1]:
				cost = 1

			var inner_min = min(matrix.get_value(i, j - 1) + 1, matrix.get_value(i - 1, j - 1) + cost)
			var new_value = min(matrix.get_value(i - 1, j - 1) + 1, inner_min)
			matrix.set_data(new_value, i, j)

	# -1 because the flatten array is using index values starting at 0
	return matrix.get_value(length_a - 1, length_b - 1)

func _distance_sort(a: FuzzyResult, b: FuzzyResult) -> int:
	return a.distance < b.distance