#!/usr/bin/env python3
"""Small SSH-based VPN-style client.

The client opens an SSH dynamic port forward (SOCKS5 proxy) and keeps it
running until interrupted. Point applications or the OS proxy settings at the
reported local address to route TCP traffic through the SSH server.
"""

from __future__ import annotations

import argparse
import shutil
import signal
import subprocess
import sys
from dataclasses import dataclass
from typing import Sequence


@dataclass(frozen=True)
class SshVpnConfig:
    host: str
    user: str | None
    port: int
    local_host: str
    local_port: int
    identity_file: str | None
    extra_ssh_args: tuple[str, ...]

    @property
    def destination(self) -> str:
        return f"{self.user}@{self.host}" if self.user else self.host


def build_ssh_command(config: SshVpnConfig) -> list[str]:
    """Build the SSH command for a local SOCKS5 tunnel."""
    command = [
        "ssh",
        "-N",
        "-D",
        f"{config.local_host}:{config.local_port}",
        "-p",
        str(config.port),
        "-o",
        "ExitOnForwardFailure=yes",
        "-o",
        "ServerAliveInterval=30",
        "-o",
        "ServerAliveCountMax=3",
    ]

    if config.identity_file:
        command.extend(["-i", config.identity_file])

    command.extend(config.extra_ssh_args)
    command.append(config.destination)
    return command


def parse_args(argv: Sequence[str]) -> SshVpnConfig:
    parser = argparse.ArgumentParser(
        description=(
            "Start a VPN-style SOCKS5 tunnel over SSH. Configure your apps to "
            "use the printed local proxy address."
        )
    )
    parser.add_argument("host", help="SSH server hostname or IP address")
    parser.add_argument("-u", "--user", help="SSH username")
    parser.add_argument("-p", "--port", type=int, default=22, help="SSH port (default: 22)")
    parser.add_argument(
        "--local-host",
        default="127.0.0.1",
        help="Local interface for the SOCKS5 proxy (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--local-port",
        type=int,
        default=1080,
        help="Local SOCKS5 proxy port (default: 1080)",
    )
    parser.add_argument("-i", "--identity-file", help="SSH private key path")
    parser.add_argument(
        "--ssh-arg",
        action="append",
        default=[],
        help="Additional raw argument passed to ssh; repeat for multiple args",
    )
    args = parser.parse_args(argv)

    return SshVpnConfig(
        host=args.host,
        user=args.user,
        port=args.port,
        local_host=args.local_host,
        local_port=args.local_port,
        identity_file=args.identity_file,
        extra_ssh_args=tuple(args.ssh_arg),
    )


def main(argv: Sequence[str] | None = None) -> int:
    config = parse_args(sys.argv[1:] if argv is None else argv)
    if shutil.which("ssh") is None:
        print("error: ssh executable was not found in PATH", file=sys.stderr)
        return 127

    command = build_ssh_command(config)
    proxy = f"socks5://{config.local_host}:{config.local_port}"
    print(f"Starting SSH VPN-style SOCKS5 tunnel at {proxy}")
    print("Set your browser/app proxy to this address. Press Ctrl+C to stop.")

    process = subprocess.Popen(command)

    def stop_tunnel(signum: int, _frame: object) -> None:
        print(f"\nStopping tunnel after signal {signum}...")
        process.terminate()

    signal.signal(signal.SIGINT, stop_tunnel)
    signal.signal(signal.SIGTERM, stop_tunnel)

    return process.wait()


if __name__ == "__main__":
    raise SystemExit(main())
