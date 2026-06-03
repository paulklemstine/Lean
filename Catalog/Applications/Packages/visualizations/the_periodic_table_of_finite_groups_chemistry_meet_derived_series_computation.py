def derived_series(G):
    series = [set(range(G.order))]
    while True:
        H = series[-1]
        Hp = G.commutator_subgroup(H)
        if Hp == H: break
        series.append(Hp)
        if Hp == {0}: break
    return series