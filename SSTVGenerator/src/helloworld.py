
import datetime

def test(str) -> str:
    time_now = datetime.datetime.now()
    return f"Hello, {str}. Current time is: {time_now}"
