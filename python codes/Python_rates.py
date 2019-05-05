import csv

fieldnames = []
writerows = []

with open('ProvidersData_withlonlat.csv') as file:

  reader = csv.DictReader(file)


  rows = []
  for row in reader:
    rows.append(row)

  myset = set()

  for row in rows:
    ratescol = row['Rates.y'].strip()
    if ratescol == 'NA':
      continue
    breakdown = ratescol.split(',')
    for rate in breakdown:
      rate = rate.strip()
      ratebreak = rate.split(':')
      if len(ratebreak) == 3:
        myset.add(ratebreak[0].strip())

  fieldnames = list(rows[1].keys()) + list(myset)

  for row in rows:
    ratescol = row['Rates.y'].strip()
    if ratescol != 'NA':   
      breakdown = ratescol.split(',')

      prev = ''
      for rate in breakdown:
        rate = rate.strip()
        ratebreak = rate.split(':')
        if len(ratebreak) == 3:
          prev = ratebreak[0].strip()
          row[prev] = 'Yes'

    for ratekey in myset:
      if ratekey not in row:
        #no possible conditions if not in myset, ratescol == NA or no data for ratekey like infant] 
        if ratescol == 'NA':
          row[ratekey]='Unknown'
        else:
          row[ratekey] = 'No'

    writerows.append(row)

  

with open('ProvidersData_withlonlat_332019.csv', 'w') as writefile:
  writer = csv.DictWriter(writefile, fieldnames=fieldnames,lineterminator='\n')
  writer.writeheader()
  for row in writerows:
    writer.writerow(row)
