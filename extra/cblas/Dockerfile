# Use the latest Debian slim image
FROM debian:bookworm-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Install necessary packages including BLAS and CBLAS
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    git \
    libopenblas-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /app

# Clone the pycparser repository
RUN git clone https://github.com/eliben/pycparser.git

# Create a virtual environment and install pycparser
RUN python3 -m venv /app/venv && \
    . /app/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install ./pycparser

# Set the virtual environment as the default
ENV PATH="/app/venv/bin:$PATH"

# Set the working directory to workspace directory
WORKDIR /app/workspace

# Set the default command to a shell that runs the script
CMD ["/bin/bash"]
