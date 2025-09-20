# 1. Base Image
FROM debian:bullseye-slim

# 2. Install Dependencies
RUN apt-get update && apt-get install -y \
    fortunes \
    cowsay \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# 3. Add Games Directory to PATH (This is the fix!)
# The 'fortune' and 'cowsay' executables are in /usr/games, which we add to the PATH.
ENV PATH="/usr/games:${PATH}"

# 4. Verify Installation
# This step will now succeed because the shell can find the commands.
RUN command -v fortune && command -v cowsay

# 5. Copy and Prepare the Script
COPY wisecow.sh /wisecow.sh
RUN chmod +x /wisecow.sh

# 6. Expose Port and Run
EXPOSE 4499
CMD ["/wisecow.sh"]