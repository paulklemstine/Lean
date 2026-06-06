def play_game(mortal, eternity, n):
    banned = set()
    for i in range(n):
        pos = mortal(banned)
        if pos in banned:
            return False
        banned.add(eternity(banned, pos))
    return True