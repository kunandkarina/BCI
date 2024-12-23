from pylsl import resolve_stream
from pylsl import StreamInlet
from time import monotonic, sleep
import queue
import time

thres = 0.0  # threshold
qsize = 30   # max queue size

def main():
    q = queue.Queue(maxsize=qsize)
    streams = resolve_stream('name', 'OpenViBE Stream1')
    inlet = StreamInlet(streams[0])
    start = monotonic()

    while True:
        sample, timestamp = inlet.pull_chunk()
        if timestamp:
            sample = sample[0][0]
            # print(sample)  # find fish
            while q.qsize() >= qsize:
                _ = q.get()
            q.put(sample)

            ratio = sum(list(q.queue)) / q.qsize()
            end = monotonic()
            print(end-start)
            if(end-start > 10):
                print("-----------------------------")
                start = monotonic()

            if ratio > thres and q.qsize() == qsize:
                print("move forward", ratio)
            else:
                print("stop ", ratio)
        time.sleep(0.2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        exit(0)
