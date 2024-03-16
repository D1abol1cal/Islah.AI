import csv

def find_max_min_rows(csv_filename, label_column_index, target_column_index):
    max_row = None
    min_row = None
    max_value = float('-inf')
    min_value = float('inf')

    with open(csv_filename, 'r') as csvfile:
        csv_reader = csv.reader(csvfile)
        header = next(csv_reader)  # Assuming the first row is the header

        for row in csv_reader:
            try:
                label_value = int(row[label_column_index])
                target_value = float(row[target_column_index])

                if label_value == 1:
                    if target_value > max_value:
                        max_value = target_value
                        max_row = row.copy()

                    if target_value < min_value:
                        min_value = target_value
                        min_row = row.copy()
            except (ValueError, IndexError):
                print("Error parsing row:", row)

    return max_row, min_row

# Example usage:
csv_filename = 'C:/Users/syedn/OneDrive/Desktop/Islah.AI-FinalYearProject-ComputerVision/Islah.AI-FinalYearProject-ComputerVision/sajda/knee-train.csv'
label_column_index = 1
target_column_index = 0
max_row, min_row = find_max_min_rows(csv_filename, label_column_index, target_column_index)

print("Row with maximum value:", max_row)
print("Row with minimum value:", min_row)
