import logging
from pathlib import Path

CUR_DIR = Path(__file__).resolve().parent
LOG_DIR = CUR_DIR / "results"
LOGGER_NAME = "output"

LOG_DIR.mkdir(exist_ok=True)


def get_logger(name: str = LOGGER_NAME, level: int = logging.INFO) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.propagate = False

    if logger.handlers:
        return logger

    fh = logging.FileHandler(LOG_DIR / f"{name}.log", mode="w")
    fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")
    fh.setFormatter(fmt)

    logger.addHandler(fh)
    logger.info("_____________START TESTS_____________")

    return logger
