import os
import asyncio
import aristotlelib
from pathlib import Path

def _load_env_file():
    env_path = Path(__file__).parent / '.env'
    if env_path.exists():
        for line in env_path.read_text(encoding='utf-8').splitlines():
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                k, v = line.split('=', 1)
                k = k.strip()
                v = v.strip().strip("'\"")
                if k and k not in os.environ:
                    os.environ[k] = v

async def main():
    _load_env_file()
    api_key = os.environ.get('ARISTOTLE_API_KEY')
    if api_key: aristotlelib.set_api_key(api_key)
    projs = await aristotlelib.Project.list_projects()
    if len(projs) > 0:
        print(type(projs[0]))
        print(projs[0])

asyncio.run(main())
