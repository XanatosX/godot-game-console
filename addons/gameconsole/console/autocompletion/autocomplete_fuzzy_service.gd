class_name FuzzyAutocompleteService extends AutocompleteService

## This will define how far away an entry can be defined by the Damerau-Levenshtein distance calculation
@export var min_allowed_distance: int = 2
@export var max_allowed_distance: int = 10

class FuzzyResult:
	var result: StrippedCommand
	var distance: int

	func _init(command: StrippedCommand, calculated_distance: int):
		result = command
		distance = calculated_distance

func _init():
	if max_allowed_distance < min_allowed_distance:
		max_allowed_distance += min_allowed_distance

func search_autocomplete(typed: String) -> Array[StrippedCommand]:
	var result_set: Array[FuzzyResult] = []
	for possible_command in Console._get_autocomplete_commands():
		var distance: int = _calculate_distance(typed, possible_command.command)
		if typed.length() >= 3 and possible_command.command.begins_with(typed):
			distance = 0

		if typed.length() >= 3 and possible_command.command.contains(typed):
			distance = min(distance, 3)
		if distance >= _get_max_allowed_difference(typed.length()):
			continue

		result_set.append(FuzzyResult.new(possible_command, distance))

	result_set.sort_custom(_distance_sort)
	var return_data: Array[StrippedCommand]
	for data in result_set:
		return_data.append(data.result)

	return return_data

func _get_max_allowed_difference(input_length: int) -> int:
	if input_length <= 3:
		return 1 + min_allowed_distance
	if input_length <= 6:
		return 2 + min_allowed_distance
	if input_length <= 10:
		return 3 + min_allowed_distance
	return max_allowed_distance

func _calculate_distance(search: String, source: String) -> int:
	var length_a: int = search.length()
	var length_b: int = source.length()

	if length_a == 0:
		return length_b
	if length_b == 0:
		return length_a

	var matrix: Array[Array] = []		
	for i in length_a + 1:
		matrix.append([])
		for j in length_b + 1:
			matrix[i].append(0)

	for i in length_a + 1:
		matrix[i][0] = i
	for j in length_b + 1:
		matrix[0][j] = j

	for i in range(1, length_a + 1):
		for j in range(1, length_b + 1):
			var cost: int = 1
			if search[i - 1] == source[j - 1]:
				cost = 0

			var deletion = matrix[i - 1][j] + 1
			var insertion = matrix[i][j - 1] + 1
			var substitution = matrix[i - 1][j - 1] + cost
			matrix[i][j] = min(deletion, insertion, substitution)

			if i > 1 and j > 1:
				if search[i - 1] == source[j - 2] and search[i - 2] == source[j - 1]:
						matrix[i][j] = min(matrix[i][j], matrix[i - 2][j - 2] + cost)

	return matrix[length_a][length_b]

func _distance_sort(a: FuzzyResult, b: FuzzyResult) -> bool:
	if a.distance == b.distance:
		return a.result.command < b.result.command
	return a.distance < b.distance