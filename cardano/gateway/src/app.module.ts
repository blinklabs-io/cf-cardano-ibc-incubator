import { Logger, Module } from '@nestjs/common';
import { TxModule } from './tx/tx.module';
import { QueryModule } from './query/query.module';
import DatabaseConfig from './config/database.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import configuration from './config';
import { LucidModule } from './shared/modules/lucid/lucid.module';
import { MiniProtocalsModule } from './shared/modules/mini-protocals/mini-protocals.module';
import { ApiModule } from './api/api.module';
import { MithrilModule } from './shared/modules/mithril/mithril.module';

@Module({
  imports: [
    TypeOrmModule.forRoot(DatabaseConfig),
    ConfigModule.forRoot({
      load: [
        configuration,
        () => ({
          deployment: require(process.env.HANDLER_JSON_PATH || '../deployment/offchain/handler.json'),
        }),
      ],
      isGlobal: true,
    }),
    QueryModule,
    TxModule,
    LucidModule,
    MiniProtocalsModule,
    ApiModule,
    MithrilModule,
  ],
  providers: [Logger],
})
export class AppModule {}
