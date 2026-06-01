def csidh_keygen(ga, x0):
    s = random.randint(0, ga.n-1)
    return (s, ga.act(s, x0))

def csidh_shared(ga, s, pk):
    return ga.act(s, pk)