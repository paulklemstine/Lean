import os

def main():
    path = "aether.log"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    print(f"Total lines in {path}: {len(lines)}")
    print("Last 100 lines:")
    for line in lines[-100:]:
        print(line, end='')

if __name__ == '__main__':
    main()
