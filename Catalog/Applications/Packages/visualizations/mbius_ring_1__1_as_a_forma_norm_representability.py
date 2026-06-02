def is_mobius_norm(n): return n % 4 != 2
def witness(n):
  if n % 4 == 2: return None
  if n % 2 == 1: return ((n+1)//2, (n-1)//2)
  return (n//4 + 1, n//4 - 1)