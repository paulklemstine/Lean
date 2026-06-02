def simplify_braid(word):
    changed = True
    while changed:
        changed = False
        i = 0
        while i < len(word) - 1:
            if (word[i][0] == word[i+1][0] and word[i][1] != word[i+1][1]):
                word.pop(i); word.pop(i)
                changed = True
            else:
                i += 1
    return word