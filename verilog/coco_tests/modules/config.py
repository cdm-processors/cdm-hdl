import os.path
import logging

CUR_DIR = os.path.dirname(os.path.realpath(__file__))
LOG_DIR = os.path.join(CUR_DIR, "results")
LOGGER_NAME = "output"

if not os.path.exists(LOG_DIR):
    os.mkdir(LOG_DIR)

def get_logger(name: str = LOGGER_NAME, level: int = logging.INFO) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(level)

    fh = logging.FileHandler(
        os.path.join(LOG_DIR, f"{name}.log"),
        mode="w"
    )
    fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")
    fh.setFormatter(fmt)
    logger.addHandler(fh)
    logger.info("_____________START TESTS_____________")

    return logger
