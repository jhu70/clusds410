import csv

fieldnames = []
sumcapacity = 0 

with open('ProvidersData_withlonlat_332019.csv') as file:

  reader = csv.DictReader(file)


  rows = []
  for row in reader:
    rows.append(row)

  for row in rows: #把那一行所有内容转换成dicionay的形式）
    school_age = row['School Age'].strip()
    preschool = row['Preschool'].strip()
    toddler = row['Toddler'].strip()
    infant = row['Infant'].strip()
    
    if (school_age == 'Yes' and preschool == 'No' and toddler == 'No' and infant == 'No'):
        row['early_ed'] = 'False'
    elif school_age == 'Unknown':
        row['early_ed'] = 'Unknown'
    else:
        row['early_ed'] = 'True'
        
    minage = row['MinimumAgeYear'].strip()
    if school_age == 'Unknown': 
        if minage == 'NA':
            row['early_ed'] = 'True'        
        elif int(minage) > 5:
            row['early_ed'] = 'False'
        elif int(minage) <= 5:
            row['early_ed'] = 'True'

    if row['early_ed'] == "True":
        sumcapacity = sumcapacity + int(row['Capacity']) 

  for row in rows:
    
    row['totalcapacity_early_ed'] = int(sumcapacity)
    
  fieldnames = list(rows[1].keys())
#不要能放fow row前面 不然以为block结束
print(sumcapacity)

with open('ProvidersData_earlyed_462019.csv', 'w') as writefile:
  writer = csv.DictWriter(writefile, fieldnames=fieldnames,lineterminator='\n')
  writer.writeheader()
  for row in rows:
    writer.writerow(row)
