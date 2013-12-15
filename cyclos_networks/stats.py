import matplotlib.pyplot as plt
import numpy as np
import filter as letsf
from sets import Set


def account_ballance(trans):
    import datetime as dt
    import collections
    bals = {}
    first_date = None
    last_day = 0
    for row in enumerate(trans[:,(1,2,4,5)]):
        from_id, to_id, datestr, brks = row[1]
        date = dt.datetime.strptime(datestr[:10], '%Y-%m-%d').date()
        brks = float(brks)
        if first_date is None:
            first_date = date

        if bals.has_key(from_id):
            bals[from_id][0].append(bals[from_id][0][-1] - brks)
        else:
            bals[from_id] = ([],[]) # (ballance,day)
            bals[from_id][0].append(-brks)
        bals[from_id][1].append((date-first_date).days)

        if bals.has_key(to_id):
            bals[to_id][0].append(bals[to_id][0][-1] + brks)
        else:
            bals[to_id] = ([],[])
            bals[to_id][0].append(brks)
        bals[to_id][1].append((date-first_date).days)
        last_day = bals[to_id][1][-1]
    for bal in bals:
        bals[bal][0].append(bals[bal][0][-1])
        bals[bal][1].append(last_day)

    return bals

def plot_bals(bals):
    
    fig = plt.figure()
    ax = fig.add_subplot(111)
    lines = []
    for bal in bals:
        line, = ax.step(bals[bal][1],bals[bal][0],where='post',label=bal)
        lines.append(line)
    leg = ax.legend(loc='upper left')
    lined = dict()
    lined2 = dict()
    for legline, origline in zip(leg.get_lines(), lines):
        legline.set_picker(5)  # 5 pts tolerance
        origline.set_picker(5)  # 5 pts tolerance
        lined[legline] = origline
        lined2[origline] = legline
    def onpick(event):
        print event
        # on the pick event, find the orig line corresponding to the
        # legend proxy line, and toggle the visibility
        if lined.has_key(event.artist):
            legline = event.artist
            origline = lined[legline]
        else:
            origline = event.artist
            legline = lined2[origline]
        vis = not origline.get_visible()
        origline.set_visible(vis)
        # Change the alpha on the line in the legend so we can see what lines
        # have been toggled
        if vis:
            legline.set_alpha(1.0)
        else:
            legline.set_alpha(0.2)
        fig.canvas.draw()
    fig.canvas.mpl_connect('pick_event', onpick)
    plt.show()

def plot_bals_matrix(bals,filename='analyza/balances.png'):
    fig = plt.figure(figsize=(20, 42), dpi=100)
    #splot = [19,5,0]
    #splot = [47,2,0]
    splot = [31,3,0]
    mx = 0
    miny = 0
    maxy = 0
    for i in bals:
        n = bals[i][1][-1]
        l = bals[i][0][-1]
        if n > mx:
            mx = n
        if miny > l:
            miny = l
        if maxy < l:
            maxy = l

    for bal in sorted(bals.keys(), key=lambda item: int(item)):
        splot[2] = splot[2] + 1
        ax = fig.add_subplot(splot[0], splot[1], splot[2])
        ax.step(bals[bal][1],bals[bal][0],where='post',label=bal)
        ax.set_xlim([0,mx])
        ax.set_ylim([miny,maxy])
        ax.axhline(linewidth=1, color='black')
        leg = ax.legend(loc='upper left')
    plt.savefig(filename)

def plot_bals_diff_matrix(bals1, bals2, filename='analyza/balances_diff.png'):
    fig = plt.figure(figsize=(20, 42), dpi=100)
    #splot = [19,5,0]
    #splot = [47,2,0]
    splot = [31,3,0]
    mx = 0
    miny = 0
    maxy = 0
    for i in bals1:
        n = bals1[i][1][-1]
        l = bals1[i][0][-1]
        if n > mx:
            mx = n
        if miny > l:
            miny = l
        if maxy < l:
            maxy = l
    for i in bals2:
        n = bals2[i][1][-1]
        l = bals2[i][0][-1]
        if n > mx:
            mx = n
        if miny > l:
            miny = l
        if maxy < l:
            maxy = l

    for bal in sorted(bals1.keys(), key=lambda item: int(item)):
        if not bals2.has_key(bal):
            continue
        splot[2] = splot[2] + 1
        ax = fig.add_subplot(splot[0], splot[1], splot[2])
        ax.step(bals1[bal][1],bals1[bal][0],where='post',label=bal,color='blue')
        ax.step(bals2[bal][1],bals2[bal][0],where='post',label=bal+"'", color='red')
        ax.set_xlim([0,mx])
        ax.set_ylim([miny,maxy])
        ax.axhline(linewidth=1, color='black')
        leg = ax.legend(loc='upper left')
    plt.savefig(filename)

def plot_bals_diffs(bals1, bals2, nodes, filename='analyza/ballances_33.pdf'):
    #fig = plt.figure(figsize=(8, 4), dpi=100)
    fig = plt.figure(figsize=(8, 4))
    nrows = np.ceil(len(nodes)/2.0)
    mx = 0
    miny = 0
    maxy = 0
    for i in bals1:
        n = bals1[i][1][-1]
        l = bals1[i][0][-1]
        if n > mx:
            mx = n
        if miny > l:
            miny = l
        if maxy < l:
            maxy = l
    for i in bals2:
        n = bals2[i][1][-1]
        l = bals2[i][0][-1]
        if n > mx:
            mx = n
        if miny > l:
            miny = l
        if maxy < l:
            maxy = l
    for i,bal in enumerate(nodes):
        ax = fig.add_subplot(nrows, 2, i)
        ax.plot(bals1[bal][1],bals1[bal][0],label=bal,linestyle='--',color='blue', drawstyle='steps-post', linewidth=3)
        ax.plot(bals2[bal][1],bals2[bal][0],label=bal+"'", linestyle='-.',color='red', drawstyle='steps-post', linewidth=3)
        ax.set_xlim([0,mx])
        #ax.set_ylim([miny,maxy])
        ax.axhline(linewidth=1, color='black')
        #leg = ax.legend(loc='lower left')
        ax.set_title('account ' + bal)
        ax.set_xlabel('time [days]')
        ax.set_ylabel('ballance [BRK]')
        plt.setp(ax.get_xticklabels(), rotation='vertical', fontsize=10)
        plt.setp(ax.get_yticklabels(), fontsize=10)
    plt.tight_layout()
    plt.savefig(filename, format='pdf')



def plot_cat_hist(cat_vol, cat_label):
    fig = plt.figure(figsize=(20,20),dpi=100)
    pos = np.arange(len(cat_vol.keys())) + 0.5
    plt.bar(pos, cat_vol.values())
    plt.xticks(pos+0.5, cat_label.values())
    fig.autofmt_xdate()
    plt.show()


def total_flow(trans):
    if trans.shape[0] > 0:
        return sum(map(float,trans[:,5]))
    else:
        return 0.0

def flow_stats(trans):
    print "month\tvolume\tcount\tmembers"
    for y in range(2011,2014):
        print y
        print
        vrl = letsf.month_filters(y)
        for k, vr in vrl.iteritems():
            month_trans = trans[vr(trans[:,4]),:]
            print "%i\t%f\t%d\t%d" % (k, total_flow(month_trans), month_trans.shape[0] , np.unique(month_trans[:,(1,2)]).shape[0])

def flow_cat_stats(trans, cats):
    print "mesic:" + ':'.join(map(lambda x: x[0],cats))

    yflows = {}
    for y in range(2011,2014):
        print y
        print
        vrl = letsf.month_filters(y)
        for k, vr in vrl.iteritems():
            flows = {}
            for cat in cats:
                t = trans[trans[:,30] == cat[1],:]
                flows[cat[1]] = total_flow(t[vr(t[:,4]),:])
            print '%i: %s' % (k, ','.join(map(lambda b: str(flows[b[1]]) ,cats)))
            yflows[(y,k)] = flows

    return yflows



def flow_cat_count_stats(trans, cats):
    print "mesic:" + ':'.join(map(lambda x: x[0],cats))

    yflows = {}
    for y in range(2011,2014):
        print y
        print
        vrl = letsf.month_filters(y)
        for k, vr in vrl.iteritems():
            flows = {}
            for cat in cats:
                t = trans[trans[:,30] == cat[1],:]
                flows[cat[1]] = t[vr(t[:,4]),:].shape[0]
            print '%i: %s' % (k, ','.join(map(lambda b: str(flows[b[1]]) ,cats)))
            yflows[(y,k)] = flows

    return yflows


def diff_bals(bals1, bals2):
    f1 = map(lambda x:(x,bals1[x][0][-1]), bals2)
    f2 = map(lambda x:(x,bals2[x][0][-1]), bals2)
    diff = map(lambda x: (x[0][0], x[1][1]-x[0][1]) ,zip(f1,f2))
    return diff
