from typing import List, Tuple

Config = Tuple[bool, ...]

def flip(a: Config, i: int) -> Config:
    return a[:i] + (not a[i],) + a[i + 1:]

def plan(a: Config, b: Config) -> List[Config]:
    path: List[Config] = [a]
    cur = a
    for i in range(len(a)):
        if cur[i] != b[i]:
            cur = flip(cur, i)
            path.append(cur)
    assert cur == b
    return path

if __name__ == '__main__':
    a = (True, True, True, True)
    b = (False, True, False, False)
    for step in plan(a, b):
        print(''.join('M' if x else 'V' for x in step))
