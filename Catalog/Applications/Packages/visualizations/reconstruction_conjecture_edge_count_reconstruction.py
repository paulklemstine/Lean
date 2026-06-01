def reconstruct_edge_count(deck, n):
    total = sum(card.edge_count() for card in deck)
    return total // (n - 2)