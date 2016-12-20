#include "usermanagement.h"
#include <QDebug>
#include <QtCore/QJsonDocument>
#include <QByteArray>
UserManagement::UserManagement(QObject *root) : QObject()
{
    this->root = root;
    if(this->root) {
        qWarning()<<"root found";
    } else {
        qWarning()<<"root not found";
    }
    sequence = 0;
#ifdef REAL_SERVER
    qWarning()<<"connecting to real server";
    connectWebsockets();
#else
    pSocket = NULL;
    connect(&timerTest, SIGNAL(timeout()), this, SLOT(slot_timerTest()));
    timerTest.setSingleShot(false);
    timerTest.start(5000);
    launchServer();
#endif
}
void UserManagement::setUser(const User &user)
{
    QMetaObject::invokeMethod(root, "languageChanged", Q_ARG(QVariant, user.graphPreferredLanguage));
    //qWarning()<<"dashboard: user language =" << user.graphPreferredLanguage;
}

void UserManagement::connectWebsockets()
{
#ifdef REAL_SERVER
    const QUrl url(REAL_SERVER);
#else
    const QUrl url(QStringLiteral("ws://localhost:1234"));
#endif
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::SecureProtocols);
    webSocket.setSslConfiguration(config);
    connect(&webSocket, &QWebSocket::connected, this, &UserManagement::onConnected);
    connect(&webSocket, &QWebSocket::disconnected, this, &UserManagement::onClosed);
    if(!connect(&webSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onWebSocketError(QAbstractSocket::SocketError)))) {
        qWarning() << "Failed to connect to QWebSocket::error";
    }
    webSocket.open(QUrl(url));
}
void UserManagement::onWebSocketError(QAbstractSocket::SocketError)
{
    qWarning()<<"Websocket error:" << webSocket.errorString();
}

void UserManagement::onConnected()
{
    connect(&webSocket, &QWebSocket::textMessageReceived,
            this, &UserManagement::onTextMessageReceived);
    QVariantList list;
    QByteArray json;
    list << 2 << QString().setNum(++sequence) << "agl-identity-agent/subscribe" << true;
    listToJson(list, &json);
    webSocket.sendTextMessage(QString(json));
}
void UserManagement::onTextMessageReceived(QString message)
{
    QVariantList list;
    const bool ok = jsonToList(message.toUtf8(), &list);
    if(!ok || list.size() < 3) {
        qWarning()<<"error 1 decoding json"<<list.size()<<message;
        return;
    }
    QVariantMap map  = list.at(2).toMap();
    if(list.first().toInt() == 5) {
        map = map["data"].toMap();
        if(map["eventName"].toString() == "login") {
            //qWarning()<<"login received in client";
            list.clear();
            list << 2 << QString().setNum(++sequence) << "agl-identity-agent/get" << true;
            QByteArray data;
            listToJson(list, &data);
            webSocket.sendTextMessage(QString(data));
        }
        return;
    }
    if(list.first().toInt() == 3) {
        if(!map.contains("response")) {
            list.clear();
            list << 2 << QString().setNum(++sequence) << "agl-identity-agent/get" << true;
            QByteArray data;
            listToJson(list, &data);
            webSocket.sendTextMessage(QString(data));
            return;
        }
        map = map["response"].toMap();
        User user;
        user.postal_address = map["postal_address"].toString();
        QStringList temp  = map["loc"].toString().split(",");
        if(temp.size() == 2) {
            user.loc.setX(temp.at(0).toDouble());
            user.loc.setY(temp.at(1).toDouble());
        }
        user.graphActions = map["graphActions"].toString().split(",");
        user.country = map["country"].toString();
        user.mail = map["mail"].toString();
        user.city = map["city"].toString();
        user.graphEmail = map["graphEmail"].toString();
        user.graphPreferredLanguage = map["graphPreferredLanguage"].toString();
        user.ccNumberMasked = map["ccNumberMasked"].toString();
        user.ccExpYear = map["ccExpYear"].toString();
        user.ccExpMonth = map["ccExpMonth"].toString();
        user.description = map["description"].toString();
        user.groups = map["groups"].toStringList();
        user.last_name = map["last_name"].toString();
        user.ccNumber = map["ccNumber"].toString();
        user.house_identifier = map["house_identifier"].toString();
        user.phone = map["phone"].toString();
        user.name = map["name"].toString();
        user.state = map["state"].toString();
        user.common_name = map["common_name"].toString();
        user.fax = map["fax"].toString();
        user.postal_code = map["postal_code"].toString();
        user.first_name = map["first_name"].toString();
        user.keytoken = map["keytoken"].toString();
        setUser(user);
    }
}

void UserManagement::onClosed()
{
    qWarning()<<"webSocket closed";
}
bool UserManagement::listToJson(const QList<QVariant> &list, QByteArray *json) const
{
    QVariant v(list);
    *json = QJsonDocument::fromVariant(v).toJson(QJsonDocument::Compact);
    return true;
}
bool UserManagement::jsonToList(const QByteArray &buf, QList<QVariant> *list) const
{
    if(!list)
        return false;
    QJsonParseError err;
    QVariant v = QJsonDocument::fromJson(buf, &err).toVariant();
    if(err.error != 0) {
        qWarning() << "Error parsing json data" << err.errorString() << buf;
        *list = QList<QVariant>();
        return false;
    }
    *list = v.toList();
    return true;
}
bool UserManagement::mapToJson( const QVariantMap &map, QByteArray *json) const
{
    if(!json)
        return false;
    QVariant v(map);
    *json = QJsonDocument::fromVariant(v).toJson(QJsonDocument::Compact);
    return true;
}
bool UserManagement::jsonToMap(const QByteArray &buf, QVariantMap *map) const
{
    if(!map)
        return false;
    QJsonParseError err;
    QVariant v = QJsonDocument::fromJson(buf, &err).toVariant();
    if(err.error != 0) {
        qWarning() << "Error parsing json data" << err.errorString() << buf;
        *map = QVariantMap();
        return false;
    }
    *map = v.toMap();
    return true;
}
#ifndef REAL_SERVER
void UserManagement::launchServer()
{
      webSocketServer = new QWebSocketServer(QStringLiteral("My Server"),
                                              QWebSocketServer::NonSecureMode, this);
      if(webSocketServer->listen(QHostAddress::Any, 1234)) {
          connect(webSocketServer, &QWebSocketServer::newConnection,
                  this, &UserManagement::onServerNewConnection);
          connect(webSocketServer, &QWebSocketServer::closed, this, &UserManagement::onServerClosed);
          QTimer::singleShot(100, this, SLOT(connectWebsockets()));
      } else {
          qWarning()<<"unable to launch webSocket server";
      }
}
void UserManagement::onServerNewConnection()
{
    pSocket = webSocketServer->nextPendingConnection();
    connect(pSocket, &QWebSocket::textMessageReceived, this, &UserManagement::processTextMessage, Qt::UniqueConnection);
    connect(pSocket, &QWebSocket::binaryMessageReceived, this, &UserManagement::processBinaryMessage, Qt::UniqueConnection);
    connect(pSocket, &QWebSocket::disconnected, this, &UserManagement::serverSocketDisconnected, Qt::UniqueConnection);
}
void UserManagement::processTextMessage(QString message)
{
    QString clientDetails_1 = "{\"postal_address\":\"201 Mission Street\",\"loc\":\"37.7914374,-122.3950694\",\"graphActions\":\"Install App,Update Software,Exceed 100 Kph,Open Trunk,View Online\""
                              ",\"country\":\"USA\",\"mail\":\"bjensen@example.com\",\"city\":\"San Francisco\",\"graphEmail\":"
                              "\"bjensen@example.com\",\"graphPreferredLanguage\":\"en\",\"ccNumberMasked\":\"-111\",\"ccExpYear\""
                              ":\"19\",\"ccExpMonth\":\"01\",\"description\":\"Original description\",\"groups\":[],\"last_name\":\""
                              "Jensen\",\"ccNumber\":\"111-2343-1121-111\",\"house_identifier\":\"ForgeRock\",\"phone\":\""
                              "+1 408 555 1862\",\"name\":\"bjensen\",\"state\":\"CA\",\"common_name\":\"Barbara Jensen\",\"fax\":\""
                              "+1 408 555 1862\",\"postal_code\":\"94105\",\"first_name\":\"Barbara\",\"keytoken\":\"a123456\"}";
    QString clientDetails_2 = "{\"postal_address\":\"201 Mission Street\",\"loc\":\"37.7914374,-122.3950694\""
                              ",\"country\":\"USA\",\"mail\":\"bjensen@example.com\",\"city\":\"San Francisco\",\"graphEmail\":"
                              "\"bjensen@example.com\",\"graphPreferredLanguage\":\"fr\",\"ccNumberMasked\":\"-222\",\"ccExpYear\""
                              ":\"19\",\"ccExpMonth\":\"01\",\"description\":\"Original description\",\"groups\":[],\"last_name\":\""
                              "Jensen\",\"ccNumber\":\"111-2343-1121-111\",\"house_identifier\":\"ForgeRock\",\"phone\":\""
                              "+1 408 555 1862\",\"name\":\"bjensen\",\"state\":\"CA\",\"common_name\":\"Barbara Jensen\",\"fax\":\""
                              "+1 408 555 1862\",\"postal_code\":\"94105\",\"first_name\":\"José\",\"keytoken\":\"a123456\"}";
    QString clientDetails = clientDetails_1;
    if(sequence % 2 == 1)
        clientDetails = clientDetails_2;
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    //qDebug() << "message received in server:" << message;
    if (!pClient)
        return;
    QVariantList list;
    if(!jsonToList(message.toUtf8(), &list))
        return;
    if(list.size() < 2)
        return;
    const int messType = list.at(0).toInt();
    const QString messId = list.at(1).toString();
    const QString cmd = list.at(2).toString();
    list.clear();
    QString reply;
    switch(messType) {
    case 2:
        if(cmd == "agl-identity-agent/subscribe") {
            reply = "[3,\"999maitai999\",{\"jtype\":\"afb-reply\",\"request\":{\"status\":\"success\",\"uuid\":\"1f2f7678-6f2e-4f54-b7b5-d0d4dcbf2e41\"}}]";
        } else if (cmd == "agl-identity-agent/get") {
            reply = "[3,\"999maitai99\",{\"jtype\":\"afb-reply\",\"request\":{\"status\":\"success\"},\"response\":....}]";
            reply = reply.replace("....", clientDetails);
        } else {
            qWarning()<<"invalid cmd received:"<<cmd;
            return;
        }
        break;
    default:
        qWarning()<<"invalid message type"<<messType;
        return;
        break;
    }
    reply = reply.replace("999maitai999", messId);
    pClient->sendTextMessage(reply);
}
void UserManagement::processBinaryMessage(QByteArray message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    qDebug() << "Binary Message received ????:" << message;
    if (pClient) {
       // pClient->sendBinaryMessage(message);
    }
}
void UserManagement::serverSocketDisconnected()
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    qDebug() << "socketDisconnected:" << pClient;
    if (pClient) {
        pClient->deleteLater();
    }
}
void UserManagement::slot_timerTest()
{
    if(!pSocket)
        return;
    pSocket->sendTextMessage("[5,\"agl-identity-agent/event\",{\"event\":\"agl-identity-agent\/event\",\"data\":{\"eventName\":\"incoming\",\"accountid\":\"D2:D4:71:0D:B5:F1\",\"nickname\":\"D2:D4:71:0D:B5:F1\"},\"jtype\":\"afb-event\"}]");
    pSocket->sendTextMessage("[5,\"agl-identity-agent/event\",{\"event\":\"agl-identity-agent\/event\",\"data\":{\"eventName\":\"login\",\"accountid\":\"null\"},\"jtype\":\"afb-event\"}]");
}
void UserManagement::onServerClosed()
{
    qWarning()<<"websocket server closed";
}
#endif
