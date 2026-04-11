import os.path
import logging

CUR_DIR = os.path.dirname(os.path.realpath(__file__))
LOGGER_NAME = "output.log"

logger = logging.getLogger("my_log")
logger.setLevel(logging.INFO)

fh = logging.FileHandler(
    os.path.join(CUR_DIR, LOGGER_NAME),
    mode="w"
)
fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")
fh.setFormatter(fmt)
logger.addHandler(fh)
