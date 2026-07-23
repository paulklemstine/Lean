from math import ceil

def place(total: int, books: int, capacity: int) -> list[tuple[int, int]]:
    if min(total, books, capacity) < 0 or total > books * capacity:
        raise ValueError("insufficient or invalid capacity")
    if total and capacity == 0:
        raise ValueError("zero capacity")
    return [divmod(i, capacity) for i in range(total)]

if __name__ == "__main__":
    total, capacity = 23, 5
    books = ceil(total / capacity)
    print(books, place(total, books, capacity))
