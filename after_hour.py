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
    monday_open_split = (monday_open.split(':')[1])
    print(monday_open_split)
    monday_opennumber = int(monday_open_split[:-2])
    monday_open_n = int(monday_open.split(':')[0]) + float(monday_opennumber/60)
    monday_close_split = (monday_close.split(':')[1])
    monday_closenumber = int(monday_close_split[:-2])
    monday_close_n = int(monday_close.split(':')[0]) + float(monday_closenumber/60)
    if monday_open == 'NA':
      row['Monday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif monday_open[-2:] == 'PM':
      row['Monday_off_hours'] = 'FALSE'
    elif monday_open_n < 7.5 and monday_close_n > 6:
      row['Monday_off_hours'] = 'TRUE'
    else:
      row['Monday_off_hours'] = 'FALSE'
    #mondaysrattime 下的每一个row的string
      
  
    tuesday_open = row['Tuesday_Start_time'].strip()
    tuesday_close = row['Tuesday_End_time'].strip()
    tuesday_open_split = (tuesday_open.split(':')[1])
    tuesday_opennumber = int(tuesday_open_split[:-2])
    tuesday_open_n = int(tuesday_open.split(':')[0]) + float(tuesday_opennumber/60)
    tuesday_close_split = (tuesday_close.split(':')[1])
    tuesday_closenumber = int(tuesday_close_split[:-2])
    tuesday_close_n = int(tuesday_close.split(':')[0]) + float(tuesday_closenumber/60)
    if tuesday_open == 'NA':
      row['Tuesday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif tuesday_open[-2:] == 'PM':
      row['Tuesday_off_hours'] = 'FALSE'
    elif tuesday_open_n < 7.5 and tuesday_close_n > 6:
      row['Tuesday_off_hours'] = 'TRUE'
    else:
      row['Tuesday_off_hours'] = 'FALSE'
  
    wed_open = row['Wednesday_Start_time'].strip()
    wed_close = row['Wednesday_End_time'].strip()
    wed_open_split = (wed_open.split(':')[1])
    wed_opennumber = int(wed_open_split[:-2])
    wed_open_n = int(wed_open.split(':')[0]) + float(wed_opennumber/60)
    wed_close_split = (wed_close.split(':')[1])
    wed_closenumber = int(wed_close_split[:-2])
    wed_close_n = int(wed_close.split(':')[0]) + float(wed_closenumber/60)
    if wed_open == 'NA':
      row['Wednesday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif wed_open[-2:] == 'PM':
      row['Wednesday_off_hours'] = 'FALSE'
    elif wed_open_n < 7.5 and wed_close_n > 6:
      row['Wednesday_off_hours'] = 'TRUE'
    else:
      row['Wednesday_off_hours'] = 'TRUE'
  
    thurs_open = row['Thursday_Start_time'].strip()
    thurs_close = row['Thursday_End_time'].strip()
    thurs_open_split = (thurs_open.split(':')[1])
    thurs_opennumber = int(thurs_open_split[:-2])
    thurs_open_n = int(thurs_open.split(':')[0]) + float(thurs_opennumber/60)
    thurs_close_split = (thurs_close.split(':')[1])
    thurs_closenumber = int(thurs_close_split[:-2])
    thurs_close_n = int(thurs_close.split(':')[0]) + float(thurs_closenumber/60)
    if thurs_open == 'NA':
      row['Thursday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif thurs_open[-2:] == 'PM':
      row['Thursday_off_hours'] = 'FALSE'
    elif thurs_open_n < 7.5 and thurs_close_n > 6:
      row['Thursday_off_hours'] = 'TRUE'
    else:
      row['Thursday_off_hours'] = 'FALSE'
      
  for row in rows:
    fri_open = row['Friday_Start_time'].strip()
    fri_close = row['Friday_End_time'].strip()
    fri_open_split = (fri_open.split(':')[1])
    fri_opennumber = int(fri_open_split[:-2])
    fri_open_n = int(fri_open.split(':')[0]) + float(fri_opennumber/60)
    fri_close_split = (fri_close.split(':')[1])
    fri_closenumber = int(fri_close_split[:-2])
    fri_close_n = int(fri_close.split(':')[0]) + float(fri_closenumber/60)
    if fri_open == 'NA':
      row['Friday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif fri_open[-2:] == 'PM':
      row['Friday_off_hours'] = 'FALSE'
    elif fri_open_n < 7.5 and fri_close_n > 6:
      row['Friday_off_hours'] = 'TRUE'
    else:
      row['Friday_off_hours'] = 'FALSE'
  
    sat_open = row['Saturday_Start_time'].strip()
    sat_close = row['Saturday_End_time'].strip()
    sat_open_split = (sat_open.split(':')[1])
    sat_opennumber = int(sat_open_split[:-2])
    sat_open_n = int(sat_open.split(':')[0]) + float(sat_opennumber/60)
    sat_close_split = (sat_close.split(':')[1])
    sat_closenumber = int(sat_close_split[:-2])
    sat_close_n = int(sat_close.split(':')[0]) + float(sat_closenumber/60)
    if sat_open == 'NA':
      row['Saturday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif sat_open[-2:] == 'PM':
      row['Saturday_off_hours'] = 'FALSE'
    elif sat_open_n < 7.5 and sat_close_n > 6:
      row['Saturday_off_hours'] = 'TRUE'
    else:
      row['Saturday_off_hours'] = 'FALSE'
  
    sun_open = row['Sunday_Start_time'].strip()
    sun_close = row['Sunday_End_time'].strip()
    sun_open_split = (sun_open.split(':')[1])
    sun_opennumber = int(sun_open_split[:-2])
    sun_open_n = int(sun_open.split(':')[0]) + float(sun_opennumber/60)
    sun_close_split = (sun_close.split(':')[1])
    sun_closenumber = int(sun_close_split[:-2])
    sun_close_n = int(sun_close.split(':')[0]) + float(sun_closenumber/60)
    if sun_open == 'NA':
      row['Sunday_off_hours'] = 'FALSE'
      #从倒数二到后面所有
    elif sun_open[-2:] == 'PM':
      row['Sunday_off_hours'] = 'FALSE'
    elif sun_open_n < 7.5 and sun_close_n > 6:
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
