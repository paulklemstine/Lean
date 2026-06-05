def depth(network, sigma):
    return sum(1 for t in network.theorems if sigma <= network.cites.get(t, set()))