def birthday_attack(hash_fn, max_attempts):
    seen = {}
    for _ in range(max_attempts):
        msg = random_message()
        h = hash_fn(msg)
        if h in seen and seen[h] != msg:
            return (msg, seen[h], h)
        seen[h] = msg
    return None