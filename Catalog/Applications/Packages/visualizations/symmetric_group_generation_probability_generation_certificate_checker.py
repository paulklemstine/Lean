def check_certificate(sigma, tau):
    n = len(sigma)
    visited = [False]*n; pos = 0; length = 0
    while not visited[pos]:
        visited[pos] = True; pos = sigma[pos]; length += 1
    if length != n: return False
    def sign(p):
        vis = [False]*len(p); cyc = 0
        for i in range(len(p)):
            if not vis[i]:
                cyc += 1; j = i
                while not vis[j]: vis[j] = True; j = p[j]
        return (-1)**(len(p)-cyc)
    return sign(sigma) == -1 or sign(tau) == -1

print(check_certificate((1,2,3,4,0), (1,0,2,3,4)))  # True