import csv

fieldnames = []

with open('ProvidersData_earlyed_462019.csv') as file:

  reader = csv.DictReader(file)

#rows 一个list, 每个row是一个dictiionary A:Apple
  #row[A]= Apple  
  rows = []
  for row in reader:
    rows.append(row)
  for row in rows:
    ##一行一行看
    #mondaysrattime 下的每一个row的string
    monday_open = row['Monday_Start_time'].strip()
    monday_close = row['Monday_End_time'].strip()
    if monday_open == 'NA':
      row['Monday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif monday_open[-2:] == 'PM':
      row['Monday_off_hours'] = 'FALSE'
    elif int(monday_open.split(':')[0]) < 8 and int(monday_open.split(':')[1]) < 3 and int(monday_close.split(':')[0]) > 6 and int(monday_close.split(':')[1]) > 2:
      row['Monday_off_hours'] = 'TRUE'
    else:
      row['Monday_off_hours'] = 'FALSE'
    #mondaysrattime 下的每一个row的string
      
  
    tuesday_open = row['Tuesday_Start_time'].strip()
    tuesday_close = row['Tuesday_End_time'].strip()
    if tuesday_open == 'NA':
      row['Tuesday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif tuesday_open[-2:] == 'PM':
      row['Tuesday_off_hours'] = 'FALSE'
    elif int(tuesday_open.split(':')[0]) < 8 and int(tuesday_open.split(':')[1]) < 3 and int(tuesday_close.split(':')[0]) > 6 and int(tuesday_close.split(':')[1]) > 2:
      row['Tuesday_off_hours'] = 'TRUE'
    else:
      row['Tuesday_off_hours'] = 'FALSE'
  
    wed_open = row['Wednesday_Start_time'].strip()
    wed_close = row['Wednesday_End_time'].strip()
    if wed_open == 'NA':
      row['Wednesday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif wed_open[-2:] == 'PM':
      row['Wednesday_off_hours'] = 'FALSE'
    elif int(wed_open.split(':')[0]) < 8 and int(wed_open.split(':')[1]) < 3 and int(wed_close.split(':')[0]) > 6 and int(wed_close.split(':')[1]) > 2:
      row['Wednesday_off_hours'] = 'TRUE'
    else:
      row['Wednesday_off_hours'] = 'TRUE'
  
    thurs_open = row['Thursday_Start_time'].strip()
    thurs_close = row['Thursday_End_time'].strip()
    if thurs_open == 'NA':
      row['Thursday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif thurs_open[-2:] == 'PM':
      row['Thursday_off_hours'] = 'FALSE'
    elif int(thurs_open.split(':')[0]) < 8 and int(thurs_open.split(':')[1]) < 3 and int(thurs_close.split(':')[0]) > 6 and int(thurs_close.split(':')[1]) > 2:
      row['Thursday_off_hours'] = 'TRUE'
    else:
      row['Thursday_off_hours'] = 'FALSE'
  for row in rows:
    fri_open = row['Friday_Start_time'].strip()
    fri_close = row['Friday_End_time'].strip()
    if fri_open == 'NA':
      row['Friday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif fri_open[-2:] == 'PM':
      row['Friday_off_hours'] = 'FALSE'
    elif int(fri_open.split(':')[0]) < 8 and int(fri_open.split(':')[1]) < 3 and int(fri_close.split(':')[0]) > 6 and int(fri_close.split(':')[1]) > 2:
      row['Friday_off_hours'] = 'TRUE'
    else:
      row['Friday_off_hours'] = 'FALSE'
  
    sat_open = row['Saturday_Start_time'].strip()
    sat_close = row['Saturday_End_time'].strip()
    if sat_open == 'NA':
      row['Saturday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif sat_open[-2:] == 'PM':
      row['Saturday_off_hours'] = 'FALSE'
    elif int(sat_open.split(':')[0]) < 8 and int(sat_open.split(':')[1]) < 3 and int(sat_close.split(':')[0]) > 6 and int(sat_close.split(':')[1]) > 2:
      row['Saturday_off_hours'] = 'TRUE'
    else:
      row['Saturday_off_hours'] = 'FALSE'
  
    sun_open = row['Sunday_Start_time'].strip()
    sun_close = row['Sunday_End_time'].strip()
    if sun_open == 'NA':
      row['Sunday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif sun_open[-2:] == 'PM':
      row['Sunday_off_hours'] = 'FALSE'
    elif int(sun_open.split(':')[0]) < 8 and int(sun_open.split(':')[1]) < 3 and int(sun_close.split(':')[0]) > 5 and int(sun_close.split(':')[1]) > 2:
      row['Sunday_off_hours'] = 'TRUE'
    else:
      row['Sunday_off_hours'] = 'FALSE'

  for row in rows:
    if row['Sunday_off_hours'] == 'TRUE' and row['Saturday_off_hours'] == 'TRUE':
      row['Weekend_off_hours'] = 'TRUE'
    else: row['Weekend_off_hours'] = 'FALSE'
    
    if row['Monday_off_hours'] == 'TRUE' and row['Tuesday_off_hours'] == 'TRUE'and row['Wednesday_off_hours'] == 'TRUE' and row['Thursday_off_hours'] == 'TRUE'and row['Friday_off_hours'] == 'TRUE':
      row['Weekdays_off_hours'] = 'TRUE'
    else: row['Weekdays_off_hours'] = 'FALSE'
    
  fieldnames = list(rows[1].keys()) 
with open('ProvidersData_earlyed_4112019.csv', 'w') as writefile:
  writer = csv.DictWriter(writefile, fieldnames=fieldnames,lineterminator='\n')
  writer.writeheader()
  for row in rows:
    writer.writerow(row)
    #把之前写好的row写进csv
