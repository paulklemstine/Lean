def cy3_mirror(h11: int, h21: int) -> tuple:
    return (h21, h11)

def cy3_euler(h11: int, h21: int) -> int:
    return 2 * (h11 - h21)