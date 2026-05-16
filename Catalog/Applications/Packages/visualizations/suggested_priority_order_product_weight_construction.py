def product_weight(wS, wT):
    return {(s, t): wS[s] + wT[t] for s in wS for t in wT}

wS = {'a': 1.0, 'b': 2.0}
wT = {'x': 0.5, 'y': 1.5}
pw = product_weight(wS, wT)
for k, v in sorted(pw.items()):
    print(f'w{k} = {v}')