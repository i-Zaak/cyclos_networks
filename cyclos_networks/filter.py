import csv
import numpy as np
import re
def load_tables(trans_file, accounts_file, categories_file=None):
    
    tr = []
    #with open('data/transfers_brno_LK_JF.csv', 'rb') as transfile:
    with open(trans_file, 'rb') as transfile:
       transreader = csv.reader(transfile, delimiter=',', quotechar='"')
       transheader = transreader.next()
       for row in transreader:
           tr.append(row)
    trans = np.array(tr)
    trans = remove_account(trans,'100')
    trans = remove_account(trans,'160')
    print "removed account 100 and 160"
    

    
    # nacteni accounts
    members = {}
    accounts = {}
    #with open('data/accounts_members_only_fixed.csv', 'rb') as accountfile:
    with open(accounts_file, 'rb') as accountfile:
        accountreader = csv.reader(accountfile, delimiter=',', quotechar='"')
        accountreader.next()
        for row in accountreader:
            members[row[7]] = {'account':row[0]}
            accounts[row[0]] = {'member':row[7]}

    if categories_file is not None:
        cats = []
        #with open('data/kategorie_lk.csv', 'rb') as catsfile:
        with open(categories_file, 'rb') as catsfile:
           catsreader = csv.reader(catsfile, delimiter=',', quotechar='"')
           catsheader = catsreader.next()
           for row in catsreader:
               cats.append(row)
        
        return trans, accounts, cats
    
    else:
       return trans, accounts


def filter_trans(trans, accounts):
    with open('data/transfers.csv', 'rb') as transfile:
        transreader = csv.reader(transfile, delimiter=',', quotechar='"')
        transheader = transreader.next()

    # vyfiltrovani transakci jen pro Brnaky
    with open('data/transfers_brno.csv', 'wb') as transfile:
        transwriter = csv.writer(transfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_ALL)
        transwriter.writerow(transheader)
        for row in trans:
            if accounts.has_key(row[1]) and accounts.has_key(row[2]):
                transwriter.writerow(row)
    
def quartal_filters():
    # rozdeleni po kvartalech (mame data 2011-03-19 - 2013-04-17)
    # pouziti: trans[vr114(trans[:,4]),:]
    r = {}
    r[111] = re.compile('2011-0[123]')
    r[112] = re.compile('2011-0[456]')
    r[113] = re.compile('2011-0[789]')
    r[114] = re.compile('2011-1[012]')
    r[121] = re.compile('2012-0[123]')
    r[122] = re.compile('2012-0[456]')
    r[123] = re.compile('2012-0[789]')
    r[124] = re.compile('2012-1[012]')
    r[131] = re.compile('2013-0[123]')
    r[132] = re.compile('2013-0[456]')
    r[133] = re.compile('2013-0[789]')
    r[134] = re.compile('2013-1[012]')
    
    vr = {}
    vr[111] = np.vectorize(lambda x:bool(r[111].match(x)))
    vr[112] = np.vectorize(lambda x:bool(r[112].match(x)))
    vr[113] = np.vectorize(lambda x:bool(r[113].match(x)))
    vr[114] = np.vectorize(lambda x:bool(r[114].match(x)))
    vr[121] = np.vectorize(lambda x:bool(r[121].match(x)))
    vr[122] = np.vectorize(lambda x:bool(r[122].match(x)))
    vr[123] = np.vectorize(lambda x:bool(r[123].match(x)))
    vr[124] = np.vectorize(lambda x:bool(r[124].match(x)))
    vr[131] = np.vectorize(lambda x:bool(r[131].match(x)))
    vr[132] = np.vectorize(lambda x:bool(r[132].match(x)))
    vr[133] = np.vectorize(lambda x:bool(r[133].match(x)))
    vr[134] = np.vectorize(lambda x:bool(r[134].match(x)))
    return vr

def half_year_filters():
    r = {}
    r[111] = re.compile('2011-0[123456]')
    r[112] = re.compile('2011-0[789]|2011-1[012]')
    r[121] = re.compile('2012-0[123456]')
    r[122] = re.compile('2012-0[789]|2011-1[012]')
    r[131] = re.compile('2013-0[123456]')
    r[132] = re.compile('2013-0[789]|2011-1[012]')
    
    vr = {}
    vr[111] = np.vectorize(lambda x:bool(r[111].match(x)))
    vr[112] = np.vectorize(lambda x:bool(r[112].match(x)))
    vr[121] = np.vectorize(lambda x:bool(r[121].match(x)))
    vr[122] = np.vectorize(lambda x:bool(r[122].match(x)))
    vr[131] = np.vectorize(lambda x:bool(r[131].match(x)))
    vr[132] = np.vectorize(lambda x:bool(r[132].match(x)))
    return vr

def month_filters(year):
    year = str(year)
    r = {}
    for i in range(1,13):
        pattern = year + '-' + format(i,"02d")
        r[i] = re.compile(pattern)
    
    vr = {}
    vr[1] = np.vectorize(lambda x:bool(r[1].match(x)))
    vr[2] = np.vectorize(lambda x:bool(r[2].match(x)))
    vr[3] = np.vectorize(lambda x:bool(r[3].match(x)))
    vr[4] = np.vectorize(lambda x:bool(r[4].match(x)))
    vr[5] = np.vectorize(lambda x:bool(r[5].match(x)))
    vr[6] = np.vectorize(lambda x:bool(r[6].match(x)))
    vr[7] = np.vectorize(lambda x:bool(r[7].match(x)))
    vr[8] = np.vectorize(lambda x:bool(r[8].match(x)))
    vr[9] = np.vectorize(lambda x:bool(r[9].match(x)))
    vr[10] = np.vectorize(lambda x:bool(r[10].match(x)))
    vr[11] = np.vectorize(lambda x:bool(r[11].match(x)))
    vr[12] = np.vectorize(lambda x:bool(r[12].match(x)))
    #for i in range(1,13):
    #    vr[i] = np.vectorize(lambda x:bool(r[i].match(x)))

    return vr

def remove_account(trans, acc):
    # acc has to be string
    acc=str(acc)
    transf = trans[(trans[:,2] != acc)*(trans[:,1] != acc)]
    return transf
