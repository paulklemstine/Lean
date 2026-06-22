import matplotlib.pyplot as plt

def primes_up_to(n):
    sieve = [True]*(n+1); sieve[0:2] = [False, False]
    for i in range(2, int(n**0.5)+1):
        if sieve[i]:
            for j in range(i*i, n+1, i): sieve[j] = False
    return [i for i in range(2, n+1) if sieve[i]]

def is_qr(a, p):
    a %= p
    if a == 0: return True
    return pow(a, (p-1)//2, p) == 1

ps = [p for p in primes_up_to(200) if p != 5]
# x^2 - x - 1 irreducible mod p  <=>  discriminant 5 is a non-residue mod p
irred = [0 if is_qr(5, p) else 1 for p in ps]
plt.figure(figsize=(10, 2.5))
plt.scatter(ps, irred, c=['#1f77b4' if v else '#d62728' for v in irred])
plt.yticks([0, 1], ['reducible', 'irreducible'])
plt.xlabel('prime p'); plt.title('Is x^2 - x - 1 irreducible over GF(p)?')
plt.savefig('irreducibility_landscape.png', dpi=160, bbox_inches='tight')
print('wrote irreducibility_landscape.png')
