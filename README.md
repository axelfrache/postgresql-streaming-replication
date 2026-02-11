# PostgreSQL - Streaming Replication

This project is an **academic lab** for the "Advanced Databases" course at **Polytech Montpellier**.

It simulates a PostgreSQL 18 streaming replication cluster using Docker Compose. It includes scripts to configure replication, test failover scenarios, and experiment with synchronous replication.

## Prerequisites

-   **Docker** and **Docker Compose** installed.
-   Port availability (containers use internal Docker network `pgnet`, exposed ports are mapped in `docker-compose.yml` if needed, but default interaction is via `docker exec`).

## Architecture

-   **pg0**: Initial Primary Server.
-   **pg1**: High-Availability Standby (Async).
-   **pg2, pg3**: Synchronous Standby candidates.
-   **Replication User**: `repluser` (password authentication).

## Quick Start

1.  **Start the Cluster**
    ```bash
    docker compose up -d
    ```
    This starts 4 PostgreSQL containers (`pg0`, `pg1`, `pg2`, `pg3`).

2.  **Initialize Primary (pg0)**
    Prepare the primary server for replication (creates user, slots, and config):
    ```bash
    docker exec pg0 psql -U postgres -f /scripts/01_replication_setup.sql
    ```

3.  **Setup Async Standby (pg1)**
    Clone `pg0` data to `pg1` and start replication:
    ```bash
    ./scripts/10_setup_standby.sh pg1 pg1_slot
    ```

## Usage Scenarios

### 1. Verification & Testing
-   **Check Replication Status**:
    ```bash
    docker exec pg0 psql -U postgres -f /scripts/06_check_replication.sql
    ```
-   **Generate Load (WAL Test)**:
    ```bash
    docker exec pg0 psql -U postgres -f /scripts/03_generate_wal.sql
    ```

### 2. Failover Simulation
Simulate a failure of `pg0` and promote `pg1` to primary.

1.  **Promote pg1**:
    ```bash
    ./scripts/11_promote_standby.sh pg1
    ```
2.  **Reconfigure pg0 as Standby**:
    After fixing the "failure", sync `pg0` back as a standby of the new primary `pg1`:
    ```bash
    ./scripts/12_failover.sh pg0 pg1 pg1_slot
    ```

### 3. Synchronous Replication
Test synchronous replication with multiple standbys (`pg2`, `pg3`).

1.  **Setup Sync Standbys**:
    ```bash
    ./scripts/22_setup_sync_standby.sh pg2 pg2_slot sync2 pg0
    ./scripts/22_setup_sync_standby.sh pg3 pg3_slot sync3 pg0
    ```
2.  **Enable Sync Commit on Primary**:
    ```bash
    docker exec pg0 psql -U postgres -f /scripts/20_enable_sync_replication.sql
    ```
3.  **Test Write Blocking**:
    Stop standbys to see writes block on the primary.
    ```bash
    docker stop pg2 pg3
    docker exec pg0 psql -U postgres -c "INSERT INTO sync_test VALUES (1);" # Will block
    ```
4.  **Disable Sync Replication**:
    ```bash
    docker exec pg0 psql -U postgres -f /scripts/21_disable_sync_replication.sql
    ```

## Key Scripts

| Script | Description |
| :--- | :--- |
| `01_replication_setup.sql` | Configures user/slots on primary. |
| `10_setup_standby.sh` | Sets up a standby via `pg_basebackup`. |
| `11_promote_standby.sh` | Promotes a standby to primary. |
| `12_failover.sh` | Rebuilds a failed primary as a standby (`pg_rewind`). |
| `20_enable_sync_replication.sql` | Sets `synchronous_standby_names` on primary. |
