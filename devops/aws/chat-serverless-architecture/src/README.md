# Real Time Chat

This is a real-time-chat-room repository written in go

## Basic Architecture Design

![architecture](./doc/pic/architecture.excalidraw.png)

## Table

This is follow single-table design.

| Entity           | PK               | SK                     | Attributes                     |
| ---------------- | ---------------- | ---------------------- | ------------------------------ |
| User information | `USER#{email}`   | `USER#{email}`         | `Username`, `Password`, `Salt` |
| History message  | `ROOM#{room_id}` | `MESSAGE#{timestamp}`  | `From`, `Content`, `TTL`       |
| Connections      | `ROOM#{room_id}` | `CONN#{connection_id}` |                                |

## Authentication Service

[file](./doc/auth.yaml)